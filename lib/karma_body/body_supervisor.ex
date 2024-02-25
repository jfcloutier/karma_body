defmodule KarmaBody.BodySupervisor do
  @moduledoc """
  Body supervisor.
  """

  use Supervisor

  require Logger

  def start_link() do
    Logger.info("Starting #{__MODULE__}")
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      {detect_body_module(), []}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end

  defp detect_body_module() do
    case KarmaBody.platform() do
      :brickpi3 -> KarmaBody.Platform.Brickpi3
      other -> raise "Unknown body module #{inspect(other)}"
    end
  end
end
