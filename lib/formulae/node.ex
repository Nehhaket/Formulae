defmodule Formulae.Node do
  defstruct [:value, :function, :left, :right]

  @type t() ::
    %{
      value: float() | nil,
      function: (Node.t(), Node.t() -> float()) | nil,
      left: Node.t() | nil,
      right: Node.t() | nil
    }
end
