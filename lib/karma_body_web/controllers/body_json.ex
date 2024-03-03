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

  def sensed(%{sensor: _id, sensed: _value} = params), do: params

  defp sensor_data(sensor), do: sensor

  defp actuator_data(actuator), do: actuator
end
