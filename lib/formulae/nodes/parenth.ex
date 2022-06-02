defmodule Formulae.Nodes.Parenth do
  @enforce_keys [:children]
  defstruct [:children]

  @type t() :: %{children: list()}
end
