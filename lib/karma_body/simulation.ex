defmodule KarmaBody.Simulation do
  @moduledoc """
  Portal to the simulation of any platform.
  """

  alias KarmaBody.Platform

  require Logger

  # How devices are connected would differentiate two devices of the same type
  @type device_connection :: atom()
  # Info produced from registration
  @type registration_receipt :: any()

  @doc """
  Register a device with its simulation.
  """
  @spec register_device(
          KarmaBody.device_class(),
          KarmaBody.device_type(),
          device_connection(),
          KarmaBody.device_properties()
        ) :: registration_receipt()
  def register_device(device_class, connection, device_type, properties) do
    Logger.info(
      "[KarmaBody] Simulation - Registering #{device_class}} #{device_type} on #{connection} with properties #{inspect(properties)}"
    )

    properties_map = Enum.into(properties, %{})

    case HTTPoison.post(
           simulation_url("register_device"),
           Jason.encode!(%{
             device_class: device_class,
             device_type: device_type,
             connection: connection,
             properties: properties_map
           }),
           [{"content-type", "application/json"}]
         ) do
      {:ok, response} ->
        answer = Jason.decode!(response.body)
        answer[:registered]

      other ->
        Logger.warning("[KarmaBody] Simulation - Regostering got unexpected #{inspect(other)}")
    end
  end

  @doc """
  Simulate sensing from a device.
  """
  @spec sense(Platform.device_id(), Platform.sense()) :: KarmaBody.sensed_value()
  def sense(device_id, sense) do
    Logger.info("[KarmaBody] Simulation - #{inspect(device_id)} sense #{inspect(sense)}")

    case HTTPoison.get(simulation_url("sense/#{device_id}/#{sense}"),
           [{"content-type", "application/json"}]
         ) do
      {:ok, response} ->
        answer = Jason.decode!(response.body)
        answer[:value]

      other ->
        Logger.warning("[KarmaBody] Simulation - Sensing got unexpected #{inspect(other)}")
        :unknown
    end
  end

  @doc """
  Simulate actuating a device.
  """
  @spec actuate(Platform.device_id(), Platform.sense()) :: :ok | {:error, :failed}
  def actuate(device_id, action) do
    Logger.info("[KarmaBody] Simulation - #{inspect(device_id)} actuate #{inspect(action)}")

    case HTTPoison.get(simulation_url("actuate/#{device_id}/#{action}"),
           [{"content-type", "application/json"}]
         ) do
      {:ok, _response} ->
        :ok

      other ->
        Logger.info("[KarmaBody] Simulation - Actuating got unexpected #{inspect(other)}")
        {:error, :failed}
    end
  end

  defp simulation_url(act) do
    platform = KarmaBody.platform()
    host = Application.get_env(:karma_body, platform)[:simulation][:host]
    "#{host}/api/#{act}"
  end
end
