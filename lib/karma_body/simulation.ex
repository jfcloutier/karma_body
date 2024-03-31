defmodule KarmaBody.Simulation do
  @moduledoc """
  Portal to the simulation of a platform.
  """

  alias KarmaBody.Platform

  require Logger

  # How devices are connected would differentiate two devices of the same type
  @type device_connection :: atom()
  # Info produced from registration
  @type registration_receipt :: any()

  @doc """
  Register the agent's body in the simulation
  """
  @spec register_body() :: :ok | {:error, HTTPoison.Error.t()}
  def register_body() do
    body_name = KarmaBody.name()
    Logger.info("[KarmaBody] Simulation - Registering body #{body_name}}")

    case HTTPoison.put(
           simulation_url("register_body/#{body_name}"),
           "",
           [{"content-type", "application/json"}]
         ) do
      {:ok, _response} ->
        :ok

      {:error, error} ->
        Logger.warning("[KarmaBody] Simulation - Registering body got error #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Register a device with its simulation.
  """
  @spec register_device(
          KarmaBody.Platform.device_id(),
          KarmaBody.device_class(),
          KarmaBody.device_type(),
          KarmaBody.device_properties()
        ) :: registration_receipt()
  def register_device(device_id, device_class, device_type, properties) do
    body_name = KarmaBody.name()

    Logger.info(
      "[KarmaBody] Simulation - Registering #{body_name}'s #{device_class} #{device_type} as #{device_id} with properties #{inspect(properties)}"
    )

    properties_map = Enum.into(properties, %{})

    case HTTPoison.post(
           simulation_url("register_device/#{body_name}"),
           Jason.encode!(%{
             body_name: KarmaBody.name(),
             device_id: device_id,
             device_class: device_class,
             device_type: device_type,
             properties: properties_map
           }),
           [{"content-type", "application/json"}]
         ) do
      {:ok, response} ->
        answer = Jason.decode!(response.body)
        answer[:registered]

      other ->
        Logger.warning(
          "[KarmaBody] Simulation - Registering device got unexpected #{inspect(other)}"
        )
    end
  end

  @doc """
  Simulate sensing from a device.
  """
  @spec sense(Platform.device_id(), Platform.sense()) :: KarmaBody.sensed_value()
  def sense(device_id, sense) do
    Logger.info("[KarmaBody] Simulation - #{inspect(device_id)} sense #{inspect(sense)}")

    body_name = KarmaBody.name()

    url = simulation_url("sense/body/#{body_name}/device/#{device_id}/sense/#{sense}")

    case HTTPoison.get(
           url,
           [{"content-type", "application/json"}]
         ) do
      {:ok, response} ->
        Logger.info("[KarmaBody] Simulation - Got #{inspect(response)} from #{inspect(url)}")
        answer = Jason.decode!(response.body)
        Map.get(answer, "value")

      other ->
        Logger.warning(
          "[KarmaBody] Simulation - Sensing got unexpected #{inspect(other)} from #{inspect(url)}"
        )

        :unknown
    end
  end

  @doc """
  Simulate actuating a device.
  """
  @spec actuate(Platform.device_id(), Platform.action()) :: :ok | {:error, :failed}
  def actuate(device_id, action) do
    Logger.info("[KarmaBody] Simulation - #{inspect(device_id)} actuate #{inspect(action)}")
    body_name = KarmaBody.name()

    case HTTPoison.get(
           simulation_url("actuate/body/#{body_name}/device/#{device_id}/action/#{action}"),
           [{"content-type", "application/json"}]
         ) do
      {:ok, _response} ->
        :ok

      other ->
        Logger.info("[KarmaBody] Simulation - Actuating got unexpected #{inspect(other)}")
        {:error, :failed}
    end
  end

  @doc """
  Execute actuations.
  """
  @spec execute_actions() :: :ok | {:error, :failed}
  def execute_actions() do
    Logger.info("[KarmaBody] Simulation - Executing actions")
    body_name = KarmaBody.name()

    case HTTPoison.get(
           simulation_url("execute_actions/#{body_name}"),
           [{"content-type", "application/json"}]
         ) do
      {:ok, _response} ->
        :ok

      other ->
        Logger.info(
          "[KarmaBody] Simulation - Executing actions got unexpected #{inspect(other)}"
        )

        {:error, :failed}
    end
  end

  defp simulation_url(act) do
    platform = KarmaBody.platform()
    host = Application.get_env(:karma_body, platform)[:simulation][:host]
    "#{host}/api/#{act}"
  end
end
