defmodule KarmaBodyWeb.BodyJSON do
  @moduledoc """
  JSON view
  """

  def index(%{sensors: sensors}) do
    %{sensors: for(sensor <- sensors, do: sensor_data(sensor))}
  end

  def index(%{actuators: actuators}) do
    %{actuators: for(actuator <- actuators, do: actuator_data(actuator))}
  end

  def sensed(%{sensor: id, sense: sense, value: value}),
    do: %{sensor: id, sense: sense, value: value}

  def actuated(%{actuator: id, action: sense, value: value}),
    do: %{actuator: id, action: sense, value: value}

  defp sensor_data(sensor), do: Map.drop(sensor, [:class])

  defp actuator_data(actuator), do: Map.drop(actuator, [:class])
end
