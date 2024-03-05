defmodule KarmaBody.Platform.Brickpi3.LegoDevice do
  @moduledoc """
  A Lego device accessable to the Brickpi3.
  """

  alias KarmaBody.Platform
  alias KarmaBody.Platform.Brickpi3
  alias KarmaBody.Platform.Brickpi3.Sysfs

  require Logger

  @typedoc """
  Lego device types
  """
  @type device_type ::
          :infrared
          | :touch
          | :gyro
          | :light
          | :ultrasonic
          | :tacho_motor

  @type t :: %__MODULE__{
          # The module implementing the device
          module: module(),
          # Whether a sensor or motor device
          class: KarmaBody.device_class(),
          # The type of sensor or motor
          type: device_type(),
          # The name of the port occupied by the device
          port: Brickpi3.device_port(),
          # Path to the lego port where mode and device can be set
          port_path: String.t(),
          # Path to where the device attribute values can be written and read
          attribute_path: String.t(),
          # device options
          options: keyword()
        }

  @type operating_mode() :: String.t()

  defstruct module: nil,
            class: nil,
            type: nil,
            port: nil,
            port_path: nil,
            attribute_path: nil,
            options: []

  @doc """
  Convert a lego device into one or more exposed sensor devices.
  """
  @callback to_exposed_sensors(t()) :: [Platform.exposed_device()]

  @doc """
  Convert a lego device into one or more exposed actuator devices.
  """
  @callback to_exposed_actuators(t()) :: [Platform.exposed_device()]

  @doc """
  Initialize the lego device's platform state given the device's options.
  """
  @callback initialize_platform(keyword()) :: :ok

  @doc """
  Make a lego device.
  """
  @spec make(keyword()) :: t()
  def make(props) do
    device_module = device_module_name(props[:type])

    lego_device = %__MODULE__{
      module: device_module,
      class: props[:class],
      type: props[:type],
      port: props[:port],
      port_path: props[:port_path],
      attribute_path: props[:attribute_path],
      options: props[:options]
    }

    device_module.initialize_platform(lego_device.options)

    Logger.debug(
      "[KarmaBody] LegoDevice - Made and initialized LegoDevice #{inspect(lego_device)}"
    )

    lego_device
  end

  @doc """
  Convert a lego device to a exposed (platform-independent) device.
  """
  @spec to_exposed_device(t(), Platform.capabilities()) :: Platform.exposed_device()
  def to_exposed_device(lego_device, capabilities) do
    %{
      id: KarmaBody.device_id(lego_device),
      url: device_url(lego_device, capabilities),
      class: lego_device.class,
      type: lego_device.type,
      capabilities: capabilities
    }
  end

  @doc """
  Set the device mode.
  """
  @spec set_operating_mode(t(), operating_mode()) :: :ok
  def set_operating_mode(lego_device, mode),
    do: Sysfs.set_operating_mode(lego_device.attribute_path, mode)

  @doc """
  Get the device's attribute value from the file system.
  """
  @spec get_attribute(t(), String.t(), Sysfs.attribute_type()) :: any()
  def get_attribute(lego_device, attribute, attribute_type),
    do: Sysfs.get_attribute(lego_device.attribute_path, attribute, attribute_type)

  defp device_module_name(device_type) do
    name = device_type |> Atom.to_string() |> Macro.camelize()
    "#{__MODULE__}.#{name}" |> String.to_atom()
  end

  defp device_url(lego_device, capabilities) do
    host_url = KarmaBody.host_url()
    device_id = Brickpi3.device_id(lego_device)

    {verb, modifier} =
      case lego_device.class do
        :sensor -> {"sense", capabilities.sense}
        :motor -> {"actuate", capabilities.action}
      end

    "#{host_url}/#{verb}/#{device_id}/#{modifier}"
  end
end
