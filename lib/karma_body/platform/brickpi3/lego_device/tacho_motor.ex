defmodule KarmaBody.Platform.Brickpi3.LegoDevice.TachoMotor do
  @moduledoc """
  A tacho motor of any size.
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  require Logger

  @behaviour LegoDevice
  @behaviour KarmaBody.Effector
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
  @spec to_exposed_effectors(KarmaBody.Platform.Brickpi3.LegoDevice.t()) :: [
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
  def to_exposed_effectors(tacho_motor),
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

    LegoDevice.set_attribute(tacho_motor, "speed_sp", speed_sp)
    LegoDevice.set_attribute(tacho_motor, "duty_cycle_sp", 100)
    LegoDevice.set_attribute(tacho_motor, "stop_action", "coast")
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

  @impl KarmaBody.Effector
  def execute(tacho_motor, %{polarity: polarity, bursts: bursts} = execution) do
    Logger.warning(
      "EXECUTING #{inspect(execution)} on motor #{inspect(tacho_motor.attribute_path)}"
    )

    burst_secs = tacho_motor.properties[:burst_secs]

    actual_polarity =
      case tacho_motor.properties[:polarity] do
        "normal" -> polarity
        "inversed" -> invert_polarity(polarity)
      end

    LegoDevice.set_attribute(tacho_motor, "polarity", actual_polarity)
    # time_sp is in milliseconds
    duration_ms = burst_secs * bursts * 1_000
    LegoDevice.set_attribute(tacho_motor, "time_sp", duration_ms)
    LegoDevice.set_attribute(tacho_motor, "command", "run-timed")
    Process.sleep(duration_ms)
    LegoDevice.set_attribute(tacho_motor, "time_sp", 0)
  end

  @impl KarmaBody.Sensor
  def sense(tacho_motor, "state"), do: LegoDevice.get_attribute(tacho_motor, "state", :string)

  def sense(tacho_motor, "position"),
    do: LegoDevice.get_attribute(tacho_motor, "position", :integer)

  @impl KarmaBody.Sensor
  def tolerance(_tacho_motor, "state"), do: 0

  def tolerance(_tacho_motor, "position"), do: 10

  # count_per_rot - The number of tacho counts in one rotation of the motor.
  # speed - tacho counts per sec
  # rpm - 60 * speed / count_per_rot
  defp rpm_to_speed(rpm, count_per_rot), do: round(rpm * count_per_rot / 60)

  # defp speed_to_rpm(speed, count_per_rot), do: round(60 * speed / count_per_rot)

  defp invert_polarity("normal"), do: "inversed"
  defp invert_polarity("inversed"), do: "normal"
end
