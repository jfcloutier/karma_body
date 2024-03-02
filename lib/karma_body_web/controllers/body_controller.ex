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

  def sense(conn, %{"id" => id, "sense" => sense}) do
    value = KarmaBody.sense(id: id, sense: sense)
    render(conn, :sensed, sensor: id, sensed: value)
  end
end
