defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Ultrasonic do
  @moduledoc """
  An ultrasound sensor capabble of sensing the distance in centimeters to an obstacle.
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  @distance_cm "US-DIST-CM"

  @impl LegoDevice
  def to_exposed_sensors(us_sensor),
    do: [
      LegoDevice.to_exposed_device(us_sensor, %{
        sense: "distance",
        # in cm
        domain: %{from: 0, to: 250}
      })
    ]

  @impl LegoDevice
  def initialize_platform(_options), do: :ok

  @impl LegoDevice
  def to_exposed_actuators(_), do: []

  @impl KarmaBody.Sensor
  def sense(us_sensor, "distance") do
    LegoDevice.set_operating_mode(us_sensor, @distance_cm)

    value = LegoDevice.get_attribute(us_sensor, "value0", :integer)

    if value > 2500, do: :unknown, else: round(value / 10)
  end
end
