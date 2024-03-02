defmodule KarmaBody.Platform.Brickpi3.LegoDevice do
  @moduledoc """
  A Lego device accessable to the Brickpi3.
  """

  alias KarmaBody.Platform
  alias KarmaBody.Platform.Brickpi3
  alias KarmaBody.Platform.Brickpi3.Sysfs

  require Logger

  @type t :: %__MODULE__{
          class: KarmaBody.device_class(),
          type: KarmaBody.device_type(),
          module: module(),
          path: String.t(),
          port: Brickpi3.device_port()
        }

  defstruct module: nil, class: nil, path: nil, port: nil, type: nil

  @doc """
  Convert a lego device into one or more exposed sensor devices.
  """
  @callback to_exposed_sensors(t()) :: [Platform.exposed_device()]

  @doc """
  Convert a lego device into one or more exposed actuator devices.
  """
  @callback to_exposed_actuators(t()) :: [Platform.exposed_device()]

  @doc """
  Make a lego device.
  """
  @spec make(keyword()) :: t()
  def make(
        class: device_class,
        path: port_path,
        port: port,
        type: device_type
      ) do
    lego_device = %__MODULE__{
      module: device_module_name(device_type),
      class: device_class,
      path: port_path,
      port: port,
      type: device_type
    }

    Logger.debug("[KarmaBody] LegoDevice - Made LegoDevice #{inspect(lego_device)}")
    lego_device
  end

  @doc """
  Convert a lego device to a exposed (platform-independent) device.
  """
  @spec to_exposed_device(t(), Platform.capabilities()) :: Platform.exposed_device()
  def to_exposed_device(lego_device, capabilities) do
    %{
      id: KarmaBody.device_id(lego_device),
      host: KarmaBody.host_url(),
      type: lego_device.type,
      capabilities: capabilities
    }
  end

  @doc """
  Get the device's attribute value from the file system.
  """
  @spec get_attribute(t(), String.t(), Sysfs.attribute_type()) :: any()
  def get_attribute(lego_device, attribute, attribute_type),
    do: Sysfs.get_attribute(lego_device.path, attribute, attribute_type)

  defp device_module_name(device_type) do
    name = device_type |> Atom.to_string() |> Macro.camelize()
    "#{__MODULE__}.#{name}" |> String.to_atom()
  end
end
