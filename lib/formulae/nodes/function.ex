defmodule Formulae.Nodes.Function do
  @enforce_keys [:func]
  defstruct [:func, :left, :right]

  @type t() :: %{func: (any, any -> number()) | (any -> number()), left: any, right: any}
end

defimpl Formulae.Runner, for: Formulae.Nodes.Function do
  alias Formulae.Nodes.Function
  alias Formulae.Runner

  def run(%Function{func: func, left: nil, right: right}) do
    func.(Runner.run(right))
  end

  def run(%Function{func: func, left: left, right: right}) do
    func.(Runner.run(left), Runner.run(right))
  end
end
