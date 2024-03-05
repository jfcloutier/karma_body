defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Touch do
  @moduledoc """
  A touch sensor
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  @impl LegoDevice
  def to_exposed_sensors(touch_sensor),
    do: [
      LegoDevice.to_exposed_device(touch_sensor, %{
        sense: "contact",
        domain: ["pressed", "released"]
      })
    ]

  @impl LegoDevice
  def to_exposed_actuators(_), do: []

  @impl LegoDevice
  def initialize_platform(_options), do: :ok

  @impl KarmaBody.Sensor
  def sense(touch_sensor, "contact") do
    case LegoDevice.get_attribute(touch_sensor, "value0", :integer) do
      0 -> "released"
      1 -> "pressed"
    end
  end
end
