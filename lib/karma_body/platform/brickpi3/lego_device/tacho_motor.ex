defmodule KarmaBody.Platform.Brickpi3.LegoDevice.TachoMotor do
  @moduledoc """
  A tacho motor
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Actuator
  @behaviour KarmaBody.Sensor

  @impl LegoDevice
  def to_exposed_sensors(tacho_motor),
    do: [
      LegoDevice.to_exposed_device(tacho_motor, %{
        sense: "state",
        domain: ~w(running ramping holding overloaded)
      })
    ]

  @impl LegoDevice
  def to_exposed_actuators(tacho_motor),
    do: [
      LegoDevice.to_exposed_device(tacho_motor, %{
        action: "turn"
      })
    ]

  @impl LegoDevice
  def initialize_platform(_options), do: :ok

  @impl KarmaBody.Actuator
  def actuate(_tacho_motor, _action), do: :ok

  @impl KarmaBody.Sensor
  def sense(tacho_motor, "state"), do: LegoDevice.get_attribute(tacho_motor, "state", :string)
end
