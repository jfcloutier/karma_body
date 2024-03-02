defmodule KarmaBody.BodySupervisor do
  @moduledoc """
  Body supervisor.
  """

  use Supervisor

  require Logger

  def start_link(_) do
    Logger.info("Starting #{__MODULE__}")
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      {detect_platform_module(), []}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end

  defp detect_platform_module() do
    case KarmaBody.platform() do
      :brickpi3 -> KarmaBody.Platform.Brickpi3
      # simulation platform goes here
      other -> raise "Unknown platform module #{inspect(other)}"
    end
  end
end
