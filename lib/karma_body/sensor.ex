defmodule KarmaBody.Sensor do
  @moduledoc """
  The sensor behaviour
  """

  alias KarmaBody.Platform

  @doc """
  Ask a device to read a sense.
  """
  @callback sense(Platform.device(), Platform.sense()) ::
              KarmaBody.sensed_value()

  @doc """
  Ask a device for the tolerance of a sense
  """
  @callback tolerance(Platform.device(), Platform.sense()) :: KarmaBody.tolerance()
end
