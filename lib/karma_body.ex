defmodule KarmaBody do
  @moduledoc """
  KarmaBody dispatches to the platform implementing the body.
  """

  alias KarmaBody.Platform

  @type host_url :: String.t()

  @typedoc """
  Device type from any of the supported platforms.
  """
  @type device_type :: atom()

  @type device_class :: :sensor | :motor

  @type sensed_value :: String.t() | integer() | :unknown

  @spec actuators() :: [Platform.exposed_device()]
  def actuators(), do: platform_module().exposed_actuators()

  @spec sensors() :: [Platform.exposed_device()]
  def sensors(), do: platform_module().exposed_sensors()

  @doc """
  Request a sensing from a device.
  """
  @spec sense(id: String.t(), sense: String.t()) :: sensed_value()
  def sense(id: device_id, sense: sense), do: platform_module().sense(device_id, sense)

  @doc """
  Request an action from a device.
  """
  @spec actuate(id: String.t(), action: String.t()) :: :ok
  def actuate(id: device_id, action: action),
    do: platform_module().actuate(device_id, action)

  @doc """
  Get platform name
  """
  @spec platform() :: atom()
  def platform(), do: Application.get_env(:karma_body, :platform)

  @doc """
  Get platform module
  """
  @spec platform_module() :: module
  def platform_module() do
    case platform() do
      :brickpi3 -> KarmaBody.Platform.Brickpi3
      other -> raise "Platform #{inspect(other)} is not supported"
    end
  end

  @doc """
  Get the URL of the body's host
  """
  @spec host_url() :: String.t()
  def host_url() do
    props = Application.get_env(:karma_body, KarmaBodyWeb.Endpoint)[:http]
    scheme = Keyword.get(props, :scheme, "http")
    port = Keyword.get(props, :port, "4000")
    {a1, a2, a3, a4} = props[:ip]
    "#{scheme}://#{a1}.#{a2}.#{a3}.#{a4}:#{port}/api"
  end

  @spec device_id(Platform.device()) :: Platform.device_id()
  def device_id(device), do: platform_module().device_id(device)
end
