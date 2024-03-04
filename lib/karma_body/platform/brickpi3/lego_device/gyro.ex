defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Gyro do
  @moduledoc """
  An gyro sensor capabble of sensing angle and rotational speed
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  @angle "GYRO-ANG"
  @rotational_speed "GYRO-RATE"

  @impl LegoDevice
  def to_exposed_sensors(gyro_sensor),
    do: [
      LegoDevice.to_exposed_device(gyro_sensor, %{
        sense: "angle",
        # -32768 to 32767, clockwise is positive
        domain: %{from: -32_768, to: 32_767}
      }),
      LegoDevice.to_exposed_device(gyro_sensor, %{
        sense: "rotational_speed",
        # -440 to 440 degrees per second, clockwise is positive
        domain: %{from: -440, to: 440}
      })
    ]

  @impl LegoDevice
  def to_exposed_actuators(_), do: []

  @impl KarmaBody.Sensor
  def sense(gyro_sensor, "angle") do
    LegoDevice.set_operating_mode(gyro_sensor, @angle)

    LegoDevice.get_attribute(gyro_sensor, "value0", :integer)
  end

  def sense(gyro_sensor, "rotational_speed") do
    LegoDevice.set_operating_mode(gyro_sensor, @rotational_speed)
    LegoDevice.get_attribute(gyro_sensor, "value0", :integer)
  end
end
