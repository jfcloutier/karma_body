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
  def sense(conn, %{"device_id" => device_id, "sense" => sense}) do
    value = KarmaBody.sense(device_id: device_id, sense: sense)
    render(conn, :sensed, sensor: device_id, sense: sense, value: value)
  end

  @doc """
  Ask an actuator to add a pending action.
  """
  def actuate(conn, %{"device_id" => device_id, "action" => action}) do
    value = KarmaBody.actuate(device_id: device_id, action: action)
    render(conn, :actuated, actuator: device_id, action: action, value: value)
  end

  @doc """
  Ask the body to execute all pending actions for all actuators.
  """
  def execute_actions(conn, _params) do
    value = KarmaBody.execute_actions()
    render(conn, :executed, value: value)
  end
end
