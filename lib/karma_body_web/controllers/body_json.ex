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

  defp sensor_data(sensor), do: %{sensor | class: "sensor"}

  defp actuator_data(actuator), do: %{actuator | class: "actuator"}
end
