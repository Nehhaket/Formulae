defmodule Formulae do
  @moduledoc """
  This module takes in math formulas (passed as a string) and returns computed value.
  If there are any unknowns it will prompt for input.
  """

  alias Formulae.{Parser, Runner}

  def run(formula, variables \\ nil) do
    if Parser.is_valid?(formula) do
      variables = maybe_get_variables(formula, variables)

      compute(formula, variables)
    else
      throw ArgumentError.exception("Invalid formula")
    end
  end

  defp compute(formula, variables) do
    formula
    |> Parser.run(variables)
    |> Runner.run()
  end

  defp maybe_get_variables(formula, nil), do: get_variables_map(formula)
  defp maybe_get_variables(_, variables), do: variables

  defp get_variables_map(formula) do
    formula
    |> Parser.get_variables_list()
    |> Enum.map(fn name ->
      value = IO.gets("Podaj warość #{name}: ") |> String.trim()
      {name, value}
    end)
    |> Map.new()
  end
end
