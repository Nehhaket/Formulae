defmodule Formulae.Runner do
  alias Formulae.Node

  def run(%Node{value: value}) when not is_nil(value), do: value

  def run(%Node{function: "-", left: %Node{value: nil, function: nil}, right: right}),
    do: -run(right)

  def run(%Node{function: "-", left: left, right: right}), do: run(left) - run(right)

  def run(%Node{function: "+", left: %Node{value: nil, function: nil}, right: right}),
    do: run(right)

  def run(%Node{function: func, left: left, right: right}) do
    if Regex.match?(~r"^[\- ]+$", func) do
      function = evaluate_minuses(func)
      run(%Node{function: function, left: left, right: right})
    else
      function = parse_function(func)
      function.(run(left), run(right))
    end
  end

  defp parse_function("+"), do: &Kernel.+/2
  defp parse_function("-"), do: &Kernel.-/2
  defp parse_function("/"), do: &Kernel.//2
  defp parse_function("*"), do: &Kernel.*/2

  defp evaluate_minuses(string) do
    string
    |> String.replace(" ", "")
    |> String.length()
    |> Kernel.rem(2)
    |> case do
      0 -> "+"
      1 -> "-"
    end
  end
end
