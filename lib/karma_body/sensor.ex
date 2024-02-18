defmodule KarmaBody.Sensor do
  @moduledoc """
  A sensor
  """

  @type t :: %__MODULE__{name: String.t()}

  defstruct name: nil
end
