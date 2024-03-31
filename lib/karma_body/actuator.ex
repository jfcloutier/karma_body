defmodule KarmaBody.Actuator do
  @moduledoc """
  The actuator behaviour
  """

  alias KarmaBody.Platform

  @doc """
  Ask a device to execute its actuation.
  """
  @callback execute(Platform.device(), map()) :: :ok
end
