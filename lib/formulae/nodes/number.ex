defmodule Formulae.Nodes.Number do
  @enforce_keys [:value]
  defstruct [:value]

  @type t() :: %{value: number()}
end

defimpl Formulae.Runner, for: Formulae.Nodes.Number do
  def run(%Formulae.Nodes.Number{value: value}), do: value
end
