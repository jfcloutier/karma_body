defmodule KarmaBody.Platform do
  @moduledoc """
  Platform behaviour.
  """

  @type device() :: any()
  @type device_id :: String.t()
  @type sense() :: String.t()
  @type action() :: String.t()
  @type domain :: [String.t()] | %{from: integer(), to: integer()}
  @type capabilities :: %{sense: sense(), domain: domain()}
  @type exposed_device() :: %{
          id: device_id(),
          host: KarmaBody.host_url(),
          type: KarmaBody.device_type(),
          capabilities: capabilities()
        }

  @doc """
  Make an identifier for the device unique to its platform
  """
  @callback device_id(device()) :: device_id()

  @doc """
  Get the device type from a device id
  """
  @callback device_type_from_id(device_id()) :: KarmaBody.device_type()

  @doc """
  Get the body's exposed sensors
  """
  @callback exposed_sensors() :: [exposed_device()]
  @doc """
  Get the body's exposed actuators
  """
  @callback exposed_actuators() :: [exposed_device()]

  @doc """
  Request a sensing.
  """
  @callback sense(device_id(), sense()) :: integer() | String.t()

  @doc """
  Request an actuation.
  """
  @callback actuate(device_id(), action()) :: :ok
end
