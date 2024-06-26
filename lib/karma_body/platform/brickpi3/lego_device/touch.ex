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
  def to_exposed_effectors(_), do: []

  @impl LegoDevice
  def initialize_platform(_device), do: :ok

  @impl LegoDevice
  def set_constants(device), do: device

  @impl KarmaBody.Sensor
  def sense(touch_sensor, "contact") do
    case LegoDevice.get_attribute(touch_sensor, "value0", :integer) do
      0 -> "released"
      1 -> "pressed"
    end
  end

  @impl KarmaBody.Sensor
  def tolerance(_touch_sensor, "contact"), do: 0
end
