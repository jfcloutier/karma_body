defmodule KarmaBody do
  @moduledoc """
  KarmaBody keeps the context, which is either a simlation or a Lego robot.
  """

  alias KarmaBody.{Simulation, Lego}

  def actuators() do
    if simulated?() do
      Simulation.Body.actuators()
    else
      Lego.Body.actuators()
    end
  end

  def sensors() do
    if simulated?() do
      Simulation.Body.sensors()
    else
      Lego.Body.sensors()
    end
  end

  defp simulated?() do
    Application.get_env(:karma_body, :simulated?, true)
  end
end
