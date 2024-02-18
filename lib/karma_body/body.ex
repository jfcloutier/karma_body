defmodule KarmaBody.Body do
  @moduledoc """
  Body behaviour.
  """

  alias KarmaBody.{Sensor, Actuator}

  @doc """
  Get the body's sensors
  """
  @callback sensors() :: [Sensor.t()]
  @doc """
  Get the body's actuators
  """
  @callback actuators() :: [Actuator.t()]
end
