defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Infrared do
  @moduledoc """
  An infrared sensor capabble of sensing the proximity and heading of an infrared beacon on channel 1.
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  @proximity "IR-PROX"
  @heading "IR-SEEK"

  @impl LegoDevice
  def to_exposed_sensors(ir_sensor) do
    channels = ir_sensor.properties |> Keyword.get(:channels, [1])

    heading_senses =
      for channel <- channels,
          do:
            LegoDevice.to_exposed_device(ir_sensor, %{
              sense: "heading_#{channel}",
              # -25 is far left, + 25 is far right
              domain: %{from: -25, to: 25}
            })

    proximity_senses =
      for channel <- channels,
          do:
            LegoDevice.to_exposed_device(ir_sensor, %{
              sense: "proximity_#{channel}",
              # 0 to 70 cms
              domain: %{from: 0, to: 70}
            })

    heading_senses ++ proximity_senses
  end

  @impl LegoDevice
  def to_exposed_actuators(_), do: []

  @impl LegoDevice
  def initialize_platform(_device), do: :ok

  @impl LegoDevice
  def set_constants(device), do: device

  @impl KarmaBody.Sensor
  def sense(ir_sensor, sense_channel) do
    case String.split(sense_channel, "_") do
      ["heading", channel_s] ->
        {channel, _} = Integer.parse(channel_s)

        LegoDevice.set_operating_mode(ir_sensor, @heading)
        # channel 1 -> value0, channel 2 -> value2
        LegoDevice.get_attribute(ir_sensor, "value#{(channel - 1) * 2}", :integer)

      ["proximity", channel_s] ->
        {channel, _} = Integer.parse(channel_s)
        LegoDevice.set_operating_mode(ir_sensor, @proximity)
        # channel 1 -> value1, channel 2 ->  value3
        value = LegoDevice.get_attribute(ir_sensor, "value#{channel * 2 - 1}", :integer)

        case value do
          100 -> :unknown
          percent -> round(percent / 100 * 70)
        end
    end
  end
end
