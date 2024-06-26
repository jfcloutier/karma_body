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

  @type device_properties :: keyword()

  @type sensed_value :: String.t() | integer() | :unknown

  @type tolerance :: non_neg_integer()

  @doc """
  The body's name. Used when simulated.
  """
  @spec name() :: String.t()
  def name(), do: Application.get_env(:karma_body, :name)

  @spec effectors() :: [Platform.exposed_device()]
  def effectors(), do: platform_module().exposed_effectors()

  @spec sensors() :: [Platform.exposed_device()]
  def sensors(), do: platform_module().exposed_sensors()

  @doc """
  Request a sensing from a device.
  """
  @spec sense(device_id: String.t(), sense: String.t()) :: {sensed_value(), tolerance}
  def sense(device_id: device_id, sense: sense) do
    value = platform_module().sense(device_id, sense)
    tolerance = platform_module().tolerance(device_id, sense)
    {value, tolerance}
  end

  @doc """
  Request an action from a device.
  """
  @spec actuate(device_id: String.t(), action: String.t()) :: :ok | {:error, :failed}
  def actuate(device_id: device_id, action: action),
    do: platform_module().actuate(device_id, action)

    @doc """
    Execute pending actions
    """
  @spec execute_actions() :: :ok | {:error, :failed}
  def execute_actions(), do: platform_module().execute_actions()

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
