defmodule KarmaBody.Lego.Body do
  @moduledoc """
  A Lego body
  """

  alias KarmaBody.{Sensor, Actuator}

  @behaviour KarmaBody.Body

  @impl KarmaBody.Body
  def sensors() do
    [%Sensor{name: "UltraSound"}, %Sensor{name: "Touch"}]
  end

  @impl KarmaBody.Body
  def actuators() do
    [%Actuator{name: "LargeMotor1"}, %Sensor{name: "LargeMotor2"}]
  end
end
