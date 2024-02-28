defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Touch do
  @moduledoc """
  A touch sensor
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice
  alias KarmaBody.Sensor

  @behaviour KarmaBody.Sensor

  @impl KarmaBody.Sensor
  def to_logical_device(lego_touch_sensor),
    do: %Sensor{
      name: LegoDevice.name(lego_touch_sensor),
      device: lego_touch_sensor,
      domain: [:not_touching, :touching]
    }

  @impl KarmaBody.Sensor
  def sense(_sensor) do
    nil
  end
end
