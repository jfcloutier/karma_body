defmodule KarmaBody.Sensor do
  @moduledoc """
  The sensor behaviour
  """

  alias KarmaBody.Platform

  @doc """
  Ask a device to sense.
  """
  @callback sense(Platform.device(), Platform.sense()) ::
              KarmaBody.sensed_value()
end
