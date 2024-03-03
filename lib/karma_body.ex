defmodule KarmaBody do
  @moduledoc """
  KarmaBody dispatches to the platform implementing the body.
  """

  alias KarmaBody.Platform

  @type host_url :: String.t()

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

  @spec actuators() :: [Platform.exposed_device()]
  def actuators(), do: platform_module().exposerd_actuators()

  @spec sensors() :: [Platform.exposed_device()]
  def sensors(), do: platform_module().exposed_sensors()

  @doc """
  Request a sensing from a device.
  """
  @spec sense(id: String.t(), sense: String.t()) :: any()
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
  @spec host_url() :: host_url()
  def host_url() do
    props = Application.get_env(:karma_body, KarmaBodyWeb.Endpoint)[:url]
    scheme = Keyword.get(props, :scheme, "http")
    port = Keyword.get(props, :port, "4000")
    "#{scheme}://#{props[:ip]}:#{port}"
  end

  @spec device_id(Platform.device()) :: Platform.device_id()
  def device_id(device), do: platform_module().device_id(device)
end
