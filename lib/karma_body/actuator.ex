defmodule KarmaBody.Actuator do
  @moduledoc """
  The actuator behaviour
  """

  alias KarmaBody.Platform

  @doc """
  Ask a device to actuate.
  """
  @callback actuate(Platform.device(), Platform.action()) :: :ok
end
