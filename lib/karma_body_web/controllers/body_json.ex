defmodule KarmaBodyWeb.BodyJSON do
  @moduledoc """
  JSON view
  """

  alias KarmaBody.{Sensor, Actuator}

  def index(%{sensors: sensors}) do
    %{sensors: for(sensor <- sensors, do: data(sensor))}
  end

  def index(%{actuators: actuators}) do
    %{actuators: for(actuator <- actuators, do: data(actuator))}
  end

  defp data(%Sensor{} = sensor), do: %{name: sensor.name}

  defp data(%Actuator{} = actuator), do: %{name: actuator.name}
end
