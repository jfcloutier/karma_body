defmodule KarmaBody do
  @moduledoc """
  KarmaBody keeps the context, which is either a simlation or a Lego robot.
  """

  alias KarmaBody.Platform.Brickpi3

  def actuators() do
    case platform() do
      :brickpi3 ->
        Brickpi3.actuators()

      other ->
        raise "Platform #{inspect(other)} is not supported"
    end
  end

  def sensors() do
    case platform() do
      :brickpi3 ->
        Brickpi3.sensors()

      other ->
        raise "Platform #{inspect(other)} is not supported"
    end
  end

  def platform(), do: Application.get_env(:karma_body, :platform)
end
