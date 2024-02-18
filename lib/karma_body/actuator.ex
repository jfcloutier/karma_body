defmodule KarmaBody.Actuator do
  @moduledoc """
  An actuator
  """

  @type t :: %__MODULE__{name: String.t()}

  defstruct name: nil
end
