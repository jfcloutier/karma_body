defmodule KarmaBody.Platform.Brickpi3.LegoDevice.TachoMotor do
  @moduledoc """
  A tacho motor of any size.
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  require Logger

  @behaviour LegoDevice
  @behaviour KarmaBody.Actuator
  @behaviour KarmaBody.Sensor

  @impl LegoDevice
  def to_exposed_sensors(tacho_motor),
    do: [
      LegoDevice.to_exposed_device(tacho_motor, %{
        sense: "state",
        domain: ~w(running ramping holding overloaded)
      }),
      LegoDevice.to_exposed_device(tacho_motor, %{
        sense: "position",
        domain: %{from: -2_147_483_648, to: 2_147_483_647}
      })
    ]

  @impl LegoDevice
  @spec to_exposed_actuators(KarmaBody.Platform.Brickpi3.LegoDevice.t()) :: [
          %{
            capabilities: %{
              optional(:action) => binary(),
              optional(:domain) => :percent | list() | map(),
              optional(:sense) => binary()
            },
            class: :motor | :sensor,
            id: nonempty_binary(),
            type: :gyro | :infrared | :light | :tacho_motor | :touch | :ultrasonic,
            url: <<_::24, _::_*8>>
          },
          ...
        ]
  def to_exposed_actuators(tacho_motor),
    do: [
      LegoDevice.to_exposed_device(tacho_motor, %{
        action: "spin"
      }),
      LegoDevice.to_exposed_device(tacho_motor, %{
        action: "reverse_spin"
      })
    ]

  @impl LegoDevice
  def initialize_platform(tacho_motor) do
    LegoDevice.set_attribute(tacho_motor, "polarity", tacho_motor.properties[:polarity])
    max_speed = tacho_motor.properties[:max_speed]

    speed_sp =
      rpm_to_speed(tacho_motor.properties[:rpm], tacho_motor.properties[:count_per_rot])
      |> min(max_speed)

    burst_secs = tacho_motor.properties[:burst_secs]
    LegoDevice.set_attribute(tacho_motor, "speed_sp", speed_sp)
    LegoDevice.set_attribute(tacho_motor, "duty_cycle_sp", 100)
    LegoDevice.set_attribute(tacho_motor, "stop_action", "coast")
    LegoDevice.set_attribute(tacho_motor, "time_sp", burst_secs * 1_000)
  end

  @impl LegoDevice
  def set_constants(tacho_motor) do
    {max_speed, count_per_rot} =
      if LegoDevice.simulated?() do
        # TODO
        {100, 100}
      else
        {LegoDevice.get_attribute(tacho_motor, "max_speed", :integer),
         LegoDevice.get_attribute(tacho_motor, "count_per_rot", :integer)}
      end

    %{
      tacho_motor
      | properties:
          Keyword.merge(tacho_motor.properties,
            max_speed: max_speed,
            count_per_rot: count_per_rot
          )
    }
  end

  @impl KarmaBody.Actuator
  def actuate(tacho_motor, "spin") do
    polarity = tacho_motor.properties[:polarity]
    LegoDevice.set_attribute(tacho_motor, "polarity", polarity)
    LegoDevice.set_attribute(tacho_motor, "command", "run-timed")
  end

  def actuate(tacho_motor, "reverse_spin") do
    polarity =
      case tacho_motor.properties[:polarity] do
        "normal" -> "inversed"
        "inversed" -> "normal"
      end

    LegoDevice.set_attribute(tacho_motor, "polarity", polarity)
    LegoDevice.set_attribute(tacho_motor, "command", "run-timed")
  end

  @impl KarmaBody.Sensor
  def sense(tacho_motor, "state"), do: LegoDevice.get_attribute(tacho_motor, "state", :string)

  def sense(tacho_motor, "position"),
    do: LegoDevice.get_attribute(tacho_motor, "position", :integer)

  # count_per_rot - The number of tacho counts in one rotation of the motor.
  # speed - tacho counts per sec
  # rpm - 60 * speed / count_per_rot
  defp rpm_to_speed(rpm, count_per_rot), do: round(rpm * count_per_rot / 60)

  # defp speed_to_rpm(speed, count_per_rot), do: round(60 * speed / count_per_rot)
end
