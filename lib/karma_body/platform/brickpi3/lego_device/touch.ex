defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Touch do
  @moduledoc """
  A touch sensor
  """

  @behaviour KarmaBody.Platform.Brickpi3.LegoDevice
  @behaviour KarmaBody.Sensor

  @impl KarmaBody.Platform.Brickpi3.LegoDevice
  def to_logical_device(lego_touch_sensor) do
    # TODO
    nil
  end

  @impl KarmaBody.Sensor
  def sense(sensor) do
    nil
  end
end
