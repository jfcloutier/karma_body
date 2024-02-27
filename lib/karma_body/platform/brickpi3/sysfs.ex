defmodule KarmaBody.Platform.Brickpi3.Sysfs do
  @moduledoc "Interface to BrickPi3 sysfs device files"

  require Logger

  @type port_name ::
          :in1
          | :in2
          | :in3
          | :in4
          | :outA
          | :outB
          | :outC
          | :outD

  @ports_path "/sys/class/lego-port"

  @doc """
  Associate the port with a device mode
  """
  @spec register_device(port_name(), KarmaBody.Platform.Brickpi3.device_type()) ::
          String.t()
  def register_device(port, device_type) do
    device_mode = device_mode(device_type)
    port_path = "#{@ports_path}/port#{port_number(port)}"
    File.write!("#{port_path}/mode", device_mode)
    # :timer.sleep(500)
    # If the device is not self-loading
    if device_type not in [:touch, :large_tacho, :medium_tacho] do
      device_code = device_code(device_type)
      :timer.sleep(500)
      File.write!("#{port_path}/set_device", device_code)
    end

    port_path
  end

  @doc "Get the typed value of an attribute of the device"
  def get_attribute(device, attribute, type) do
    value = read_sys(device.path, attribute)

    case type do
      :string ->
        value

      :atom ->
        String.to_atom(value)

      :percent ->
        {number, _} = Integer.parse(value)
        min(max(number, 0), 100)

      :integer ->
        {number, _} = Integer.parse(value)
        number

      :list ->
        String.split(value, " ")
    end
  end

  @doc "Set the value of an attribute of the device"
  def set_attribute(device, attribute, value) do
    write_sys(device.path, attribute, "#{value}")
  end

  @doc "Reading a line from a file"
  def read_sys(dir, file) do
    [line] =
      File.stream!("#{dir}/#{file}")
      |> Stream.take(1)
      |> Enum.to_list()

    String.trim(line)
  end

  @doc "Writing a line to a file"
  def write_sys(dir, file, line) do
    File.write!("#{dir}/#{file}", line)
  end

  @doc "Execute a command on a device"
  def execute_command(device, command) do
    true = command in device.props.commands
    write_sys(device.path, "command", command)
  end

  @doc "Execute a stop action on a device"
  def execute_stop_action(device, command) do
    true = command in device.props.stop_actions
    write_sys(device.path, "stop_action", command)
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
end
