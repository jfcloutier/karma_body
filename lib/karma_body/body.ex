defmodule KarmaBody.Body do
  @moduledoc """
  Body behaviour.
  """

  alias KarmaBody.{Sensor, Actuator}

  @doc """
  Get the body's logical sensors
  """
  @callback sensors() :: [Sensor.t()]
  @doc """
  Get the body's logical actuators
  """
  @callback actuators() :: [Actuator.t()]
end
