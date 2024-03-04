defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Color do
  @moduledoc """
  A touch sensor
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  @reflect "COL-REFLECT"
  @ambient "COL-AMBIENT"
  @color "COL-COLOR"

  @impl LegoDevice
  def to_exposed_sensors(color_sensor),
    do: [
      LegoDevice.to_exposed_device(color_sensor, %{
        sense: "color",
        domain: ~w(unknown black blue green yellow red white brown)
      }),
      LegoDevice.to_exposed_device(color_sensor, %{
        sense: "ambient",
        domain: :percent
      }),
      LegoDevice.to_exposed_device(color_sensor, %{
        sense: "reflected",
        domain: :percent
      })
    ]

  @impl LegoDevice
  def to_exposed_actuators(_), do: []

  @impl KarmaBody.Sensor
  def sense(color_sensor, "color") do
    LegoDevice.set_operating_mode(color_sensor, @color)

    case LegoDevice.get_attribute(color_sensor, "value0", :integer) do
      0 -> "unknown"
      1 -> "black"
      2 -> "blue"
      3 -> "green"
      4 -> "yellow"
      5 -> "red"
      6 -> "white"
      7 -> "brown"
    end
  end

  def sense(color_sensor, "ambient") do
    LegoDevice.set_operating_mode(color_sensor, @ambient)
    LegoDevice.get_attribute(color_sensor, "value0", :integer)
  end

  def sense(color_sensor, "reflected") do
    LegoDevice.set_operating_mode(color_sensor, @reflect)
    LegoDevice.get_attribute(color_sensor, "value0", :integer)
  end
end
