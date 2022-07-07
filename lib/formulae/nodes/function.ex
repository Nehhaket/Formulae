defmodule Formulae.Nodes.Function do
  @enforce_keys [:func]
  defstruct [:func, :left, :right]

  @type t() :: %{
          func:
            (any, any -> number())
            | (any -> number()),
          left: any,
          right: any
        }
end

defimpl Formulae.Runner, for: Formulae.Nodes.Function do
  def run(%Formulae.Nodes.Function{func: func, left: nil, right: right}) do
    func.(Formulae.Runner.run(right))
  end

  def run(%Formulae.Nodes.Function{func: func, left: left, right: right}) do
    func.(Formulae.Runner.run(left), Formulae.Runner.run(right))
  end
end
