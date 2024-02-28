defmodule KarmaBody.Sensor do
  @moduledoc """
  A sensor as
  """

  @type domain :: [any()]

  @type t :: %__MODULE__{name: String.t(), device: struct(), domain: domain()}

  defstruct name: nil,
  # The platform-specific device
  device: nil,
  # The range of values that can be sensed in some order
  domain: []

  @doc """
  Convert a Lego device to the logical device Karma.Agency expects
  """
  @callback to_logical_device(any()) :: t()

  @callback sense(t()) :: any() # TODO
end
