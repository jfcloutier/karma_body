defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Infrared do
  @moduledoc """
  An infrared sensor capabble of sensing the proximity and heading of an infrared beacon on channel 1.
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  @proximity "IR-PROX"
  @heading "IR-SEEK"
  @channel 1

  @impl LegoDevice
  def to_exposed_sensors(ir_sensor),
    do: [
      LegoDevice.to_exposed_device(ir_sensor, %{
        sense: "proximity",
        # in cm
        domain: %{from: 0, to: 70}
      }),
      LegoDevice.to_exposed_device(ir_sensor, %{
        sense: "heading",
        # -25 is far left, + 25 is far right
        domain: %{from: -25, to: 25}
      })
    ]

  @impl LegoDevice
  def to_exposed_actuators(_), do: []

  @impl KarmaBody.Sensor
  def sense(ir_sensor, "proximity") do
    LegoDevice.set_operating_mode(ir_sensor, @proximity)

    value = LegoDevice.get_attribute(ir_sensor, "value#{(@channel - 1) * 2}", :integer)

    case value do
      100 -> :unknown
      percent -> round(percent / 100 * 70)
    end
  end

  def sense(ir_sensor, "heading") do
    LegoDevice.set_operating_mode(ir_sensor, @heading)
    LegoDevice.get_attribute(ir_sensor, "value#{(@channel - 1) * 2}", :integer)
  end
end
