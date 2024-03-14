defmodule KarmaBody.Platform.Brickpi3.Simulation do
  @moduledoc """
  A simulation of the Brickpi3 platform.
  """

  require Logger

  def register_device(device_class, port, device_type, properties) do
    properties_map = Enum.into(properties, %{})

    response =
      HTTPoison.post(
        simulation_url("register_device"),
        Jason.encode!(%{
          device_class: device_class,
          device_type: device_type,
          port: port,
          properties: properties_map
        })
      )

    Logger.info("RESPONSE = #{inspect(response)}")
    {"", ""}
  end

  def sense(_device_id, _sense) do
    # TODO
    0
  end

  def actuate(_device_id, _action) do
    # TODO
    :ok
  end

  defp simulation_url(act) do
    host = Application.get_env(:karma_body, :brickpi3)[:simulation][:host]
    "#{host}/api/#{act}"
  end
end
