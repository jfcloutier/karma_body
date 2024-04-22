defmodule KarmaBodyWeb.BodyJSON do
  @moduledoc """
  JSON view
  """

  def index(%{sensors: sensors}) do
    %{sensors: for(sensor <- sensors, do: sensor_data(sensor))}
  end

  def index(%{effectors: effectors}) do
    %{effectors: for(effector <- effectors, do: effector_data(effector))}
  end

  def sensed(%{sensor: id, sense: sense, value: value}),
    do: %{sensor: id, sense: sense, value: value}

  def actuated(%{effector: id, action: sense, value: value}),
    do: %{effector: id, action: sense, value: value}

  def executed(%{value: value}), do: %{executed: value}

  defp sensor_data(sensor), do: Map.drop(sensor, [:class])

  defp effector_data(effector), do: Map.drop(effector, [:class])
end
