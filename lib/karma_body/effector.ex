defmodule KarmaBody.Effector do
  @moduledoc """
  The effector behaviour
  """

  alias KarmaBody.Platform

  @doc """
  Ask a device to execute its effect.
  """
  @callback execute(Platform.device(), map()) :: :ok
end
