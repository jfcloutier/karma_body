defmodule KarmaBody.Platform.Brickpi3.LegoDevice do
  @moduledoc """
  A Lego device accessable to the Brickpi3.
  """

  alias KarmaBody.Platform.Brickpi3

  require Logger

  @type t :: %__MODULE__{
          module: module(),
          class: Brickpi3.device_class(),
          path: String.t(),
          port: Brickpi3.device_port(),
          type: Brickpi3.device_type()
        }

  defstruct module: nil, class: nil, path: nil, port: nil, type: nil

  @doc """
  Make a lego device.
  """
  @spec make(keyword()) :: t()
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

  @doc """
  Make a name for the lego device.
  """
  @spec name(t()) :: String.t()
  def name(%{type: type, port: port}), do: "#{type} on #{port}"

  defp module(device_type) do
    name = device_type |> Atom.to_string() |> Macro.camelize()
    "#{__MODULE__}.#{name}" |> String.to_atom()
  end
end
