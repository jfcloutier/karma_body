defmodule KarmaBody.Platform.Brickpi3.LegoDevice do
  @moduledoc """
  A Lego device accessable to the Brickpi3.
  """

  alias KarmaBody.Platform.Brickpi3

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
    %__MODULE__{
      module: module(device_type),
      class: device_class,
      path: port_path,
      port: port,
      type: device_type
    }
  end

  defp module(device_type) do
    name = device_type |> Atom.to_string() |> Macro.camelize()
    "#{__MODULE__}.#{name}" |> String.to_atom()
  end
end
