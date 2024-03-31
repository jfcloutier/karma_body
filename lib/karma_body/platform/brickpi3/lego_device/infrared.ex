defmodule KarmaBody.Platform.Brickpi3.LegoDevice.Infrared do
  @moduledoc """
  An infrared sensor capabble of sensing the proximity and heading of an infrared beacon on a channel 1.,
  or the distance to an object reflecting the IR beam emitted by the sensor.
  """

  alias KarmaBody.Platform.Brickpi3.LegoDevice

  @behaviour LegoDevice
  @behaviour KarmaBody.Sensor

  # Diatance to an object reflecting IR emitted by the sensor
  @proximity "IR-PROX"
  # Distance and heading to a multi-channel IR beacon
  @seeking "IR-SEEK"

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

    distance_senses =
      for channel <- channels,
          do:
            LegoDevice.to_exposed_device(ir_sensor, %{
              sense: "distance_#{channel}",
              # 0 to 70 cms
              domain: %{from: 0, to: 70}
            })

    proximity_sense =
      LegoDevice.to_exposed_device(ir_sensor, %{
        sense: "proximity",
        # 0 to 70 cms
        domain: %{from: 0, to: 70}
      })

    [proximity_sense | heading_senses] ++ distance_senses
  end

  @impl LegoDevice
  def to_exposed_actuators(_), do: []

  @impl LegoDevice
  def initialize_platform(_device), do: :ok

  @impl LegoDevice
  def set_constants(device), do: device

  @impl KarmaBody.Sensor
  def sense(ir_sensor, "proximity") do
    LegoDevice.set_operating_mode(ir_sensor, @proximity)
    percent = LegoDevice.get_attribute(ir_sensor, "value0", :integer)
    round(percent / 100 * 70)
  end

  def sense(ir_sensor, sense_channel) do
    LegoDevice.set_operating_mode(ir_sensor, @seeking)

    case String.split(sense_channel, "_") do
      ["heading", channel_s] ->
        {channel, _} = Integer.parse(channel_s)

        # channel 1 -> value0, channel 2 -> value2
        LegoDevice.get_attribute(ir_sensor, "value#{(channel - 1) * 2}", :integer)

      ["distance", channel_s] ->
        {channel, _} = Integer.parse(channel_s)
        # channel 1 -> value1, channel 2 ->  value3
        value = LegoDevice.get_attribute(ir_sensor, "value#{channel * 2 - 1}", :integer)

        case value do
          -128 -> :unknown
          percent -> round(percent / 100 * 70)
        end
    end
  end
end
