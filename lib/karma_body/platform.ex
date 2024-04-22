defmodule KarmaBody.Platform do
  @moduledoc """
  Platform behaviour.
  """

  @type device() :: any()
  @type device_id :: String.t()
  @type sense() :: String.t()
  @type action() :: String.t() # "spin" | "reverse_spin"
  @type domain :: [String.t()] | :percent | %{from: integer(), to: integer()}
  @type capabilities :: %{sense: sense(), domain: domain()} | %{action: action}
  @type exposed_device() :: %{
          id: device_id(),
          url: String.t(),
          class: KarmaBody.device_class(),
          type: KarmaBody.device_type(),
          capabilities: capabilities()
        }

  @doc """
  Whether running in simulation
  """
  @callback simulated?() :: boolean()

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
  Get the body's exposed effectors
  """
  @callback exposed_effectors() :: [exposed_device()]

  @doc """
  Request a sensing.
  """
  @callback sense(device_id(), sense()) :: integer() | String.t()

  @doc """
  Accumulate an actuation of a device.
  """
  @callback actuate(device_id(), action()) :: :ok | {:error, :failed}

  @doc """
  For each effector, aggregate pending actions (they may cancel each other or be additive).
  Execute the aggregates for each effector concurrently.
  Reset pending actions.
  """
  @callback execute_actions() :: :ok | {:error, :failed}
end
