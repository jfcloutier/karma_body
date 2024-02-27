defmodule KarmaBody.Platform.Brickpi3 do
  @moduledoc """
  The Brickpi3 as body.
  """

  alias KarmaBody.Platform.Brickpi3.{LegoDevice, Sysfs}
  alias KarmaBody.Body

  use GenServer

  require Logger

  @behaviour Body

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
    {lego_sensors, lego_motors} = initialize_devices()

    {:ok, %__MODULE__{lego_motors: lego_motors, lego_sensors: lego_sensors}}
  end

  @impl Body
  def sensors() do
    GenServer.call(__MODULE__, :sensors)
  end

  @impl Body
  def actuators() do
    GenServer.call(__MODULE__, :actuators)
  end

  @impl GenServer
  def handle_call(:sensors, _from, state),
    do: {:reply, state.lego_sensors |> Enum.map(&to_logical_device/1), state}

  def handle_call(:actuators, _from, state),
    do: {:reply, state.lego_motors |> Enum.map(&to_logical_device/1), state}

  ###

  defp initialize_devices() do
    Logger.debug("[Body] Initialing devices on the BrickPi3...")

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
    Logger.debug(
      "[Body] Initializing #{inspect(device_type)} #{device_class} on port #{inspect(port)}"
    )

    port_path = Sysfs.register_device(port, device_type)

    LegoDevice.make(
      class: device_class,
      path: port_path,
      port: port,
      type: device_type
    )
  end

  defp to_logical_device(lego_device), do: lego_device.module.to_logical()
end
