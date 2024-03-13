defmodule KarmaBody.Platform.Brickpi3.Simulation do
  @moduledoc """
  A simulation of the Brickpi3 platform.
  """

  def register_device(_device_class, _port, _device_type, _properties) do
    # TODO
    {"", ""}
  end

  def sense(_device_id, _sense) do
    # TODO
    0
  end

  def actuate(_device_id, _action) do
    # TODO
    :ok
  end
end
