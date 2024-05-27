defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Light do
  @moduledoc """
  A light sensor capabble of sensing color, ambient light, and surface reflectivity.
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  @reflected "COL-REFLECT"
  @ambient "COL-AMBIENT"
  @color "COL-COLOR"

  @impl LegoDevice
  def to_exposed_sensors(light_sensor),
    do: [
      LegoDevice.to_exposed_device(light_sensor, %{
        sense: "color",
        domain: ~w(unknown black blue green yellow red white brown)
      }),
      LegoDevice.to_exposed_device(light_sensor, %{
        sense: "ambient",
        domain: :percent
      }),
      LegoDevice.to_exposed_device(light_sensor, %{
        sense: "reflected",
        domain: :percent
      })
    ]

  @impl LegoDevice
  def to_exposed_effectors(_), do: []

  @impl LegoDevice
  def initialize_platform(_device), do: :ok

  @impl LegoDevice
  def set_constants(device), do: device

  @impl KarmaBody.Sensor
  def sense(light_sensor, "color") do
    LegoDevice.set_operating_mode(light_sensor, @color)

    case LegoDevice.get_attribute(light_sensor, "value0", :integer) do
      0 -> :unknown
      1 -> "black"
      2 -> "blue"
      3 -> "green"
      4 -> "yellow"
      5 -> "red"
      6 -> "white"
      7 -> "brown"
    end
  end

  @impl KarmaBody.Sensor
  def sense(light_sensor, "ambient") do
    LegoDevice.set_operating_mode(light_sensor, @ambient)
    LegoDevice.get_attribute(light_sensor, "value0", :integer)
  end

  def sense(light_sensor, "reflected") do
    LegoDevice.set_operating_mode(light_sensor, @reflected)
    LegoDevice.get_attribute(light_sensor, "value0", :integer)
  end

  @impl KarmaBody.Sensor
  def tolerance(_light_sensor, "color"), do: 0
end
