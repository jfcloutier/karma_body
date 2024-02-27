defmodule KarmaBody.Platform.Brickpi3.LegoDevice do
  @moduledoc """
  A Lego device accessable to the Brickpi3.
  """

  alias KarmaBody.Platform.Brickpi3

  require Logger

  @type t :: %__MODULE__{
          module: module(),
          class: Brickpi3.device_class(),
          path: File.t(),
          port: Brickpi3.device_port(),
          type: Brickpi3.device_type()
        }

  defstruct module: nil, class: nil, path: nil, port: nil, type: nil

  def make(
        class: device_class,
        path: port_path,
        port: port,
        type: device_type
      ) do
    lego_device = %__MODULE__{
      module: module(device_type),
      class: device_class,
      path: port_path,
      port: port,
      type: device_type
    }

    Logger.debug("[Body] Made LegoDevice #{inspect(lego_device)}")
    lego_device
  end

  defp module(device_type) do
    name = device_type |> Atom.to_string() |> Macro.camelize()
    "#{__MODULE__}.#{name}" |> String.to_atom()
  end

  @doc """
  Convert a Lego device to the logical device Karma.Agency expects
  """
  @callback to_logical_device(t()) :: KarmaBody.Actuator.t() | KarmaBody.Sensor.t()
end
