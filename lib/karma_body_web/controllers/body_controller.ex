defmodule KarmaBodyWeb.BodyController do
  @moduledoc """
  Controller for Body
  """
  use KarmaBodyWeb, :controller

  @doc """
  Get the body's sensors.
  """
  def sensors(conn, _params) do
    sensors = KarmaBody.sensors()
    render(conn, :index, sensors: sensors)
  end

  @doc """
  Get the body's actuators.
  """
  def actuators(conn, _param) do
    actuators = KarmaBody.actuators()
    render(conn, :index, actuators: actuators)
  end

  @doc """
  Ask a sensor to sense.
  """
  def sense(conn, %{"id" => id, "sense" => sense}) do
    value = KarmaBody.sense(id: id, sense: sense)
    render(conn, :sensed, sensor: id, sense: sense, value: value)
  end

  @doc """
  Ask an actuator to act.
  """
  def actuate(conn, %{"id" => id, "action" => action}) do
    value = KarmaBody.actuate(id: id, action: action)
    render(conn, :actuated, actuator: id, action: action, value: value)
  end
end
