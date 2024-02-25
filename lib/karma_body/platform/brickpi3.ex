defmodule KarmaBody.Platform.Brickpi3 do
  @moduledoc """
  The Brickpi3 as body.
  """

  alias Brickpi3.LegoDevice
  alias KarmaBody.Body

  use GenServer

  @behaviour Body

  @ports_path "/sys/class/lego-port"

  @type t :: %__MODULE__{lego_sensors: [LegoDevice.t()], lego_motors: [LegoDevice.t()]}

  @type device_port :: :outA | :outB | :outC | :outD | :in1 | :in2 | :in3 | :in4

  @type device_type ::
          :infrared
          | :touch
          | :gyro
          | :color
          | :ultrasonic
          | :ir_seeker
          | :large_tacho
          | :medium_tacho

  @type device_class :: :sensor | :motor

  defstruct lego_sensors: [], lego_motors: []

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  @spec init(any()) :: {:ok, KarmaBody.Platform.Brickpi3.t()}
  def init(_opts) do
    {lego_sensors, lego_motors} = initialize_ports()

    {:ok, %__MODULE__{lego_motors: lego_motors, lego_sensors: lego_sensors}}
  end

  def sensors() do
    GenServer.call(__MODULE__, :lego_sensors)
    |> Enum.map(&to_logical_sensor/1)
  end

  def actuator() do
    GenServer.call(__MODULE__, :lego_motors)
    |> Enum.map(&to_logical_actuator/1)
  end

  @impl GenServer
  def handle_call(:lego_sensors, _from, state), do: {:reply, state.lego_sensors, state}

  def handle_call(:lego_motors, _from, state), do: {:reply, state.lego_motors, state}

  defp initialize_ports() do
    Application.get_env(:karma_body, :brickpi3)
    |> Enum.reduce({[], []}, fn port_config, {sensors_acc, motors_acc} ->
      cond do
        Keyword.has_key?(port_config, :sensor) ->
          lego_sensor = initialize_sensor(port_config)
          {[lego_sensor | sensors_acc], motors_acc}

        Keyword.has_key?(port_config, :motor) ->
          lego_motor = initialize_motor(port_config)
          {sensors_acc, [lego_motor | motors_acc]}
      end
    end)
  end

  defp initialize_sensor(port: port, sensor: sensor_name)
       when port in [:in1, :in2, :in3, :in4] do
    initialize_device(:sensor, port, sensor_name)
  end

  defp initialize_motor(port: port, motor: motor_name)
       when port in [:outA, :outB, :outC, :outD] do
    initialize_device(:motor, port, motor_name)
  end

  defp initialize_device(device_class, port, device_type) do
    port_path = "#{@ports_path}/port#{port_number(port)}"
    device_mode = device_mode(device_type)
    File.write!("#{port_path}/mode", device_mode)
    :timer.sleep(500)

    if not self_loading_on_brickpi?(device_type) do
      device_code = device_code(device_type)
      :timer.sleep(500)
      File.write!("#{port_path}/set_device", device_code)
    end

    LegoDevice.make(
      class: device_class,
      path: port_path,
      port: port,
      type: device_type
    )
  end

  defp port_number(port) do
    case port do
      :in1 -> 0
      :in2 -> 1
      :in3 -> 2
      :in4 -> 3
      :outA -> 4
      :outB -> 5
      :outC -> 6
      :outD -> 7
    end
  end

  defp device_mode(device_type) do
    case device_type do
      :infrared -> "ev3-uart"
      :touch -> "ev3-analog"
      :gyro -> "ev3-uart"
      :color -> "ev3-uart"
      :ultrasonic -> "ev3-uart"
      :ir_seeker -> "nxt-i2c"
      :large_tacho -> "tacho-motor"
      :medium_tacho -> "tacho-motor"
    end
  end

  defp device_code(device_type) do
    case device_type do
      :infrared -> "lego-ev3-ir"
      :touch -> "lego-ev3-touch"
      :gyro -> "lego-ev3-gyro"
      :color -> "lego-ev3-color"
      :ultrasonic -> "lego-ev3-us"
      :ir_seeker -> "ht-nxt-ir-seek-v2 0x08"
      :large_tacho -> "lego-ev3-l-motor"
      :medium_tacho -> "lego-ev3-m-motor"
    end
  end

  defp self_loading_on_brickpi?(device_type) do
    device_type in [:touch, :large, :medium]
  end

  defp to_logical_sensor(_lego_sensor) do
    # TODO
    nil
  end

  defp to_logical_actuator(_lego_motor) do
    # TODO
    nil
  end
end
