defmodule Formulae.Parser do
  alias Formulae.Node
  alias Formulae.Runner

  def is_valid?(formula) when is_binary(formula),
    do: not Regex.match?(~r"[^A-Za-z0-9()+\-*/_ ,.\t\n\r]", formula)

  def is_valid?(_), do: false

  def get_variables_list(formula) when is_binary(formula) do
    Regex.scan(~r"(?:[A-Za-z][A-Za-z0-9_]*)", formula)
  end

  def run(formula, variables \\ %{}) when is_binary(formula) do
    formula
    |> String.trim()
    |> replace_variables(variables)
    |> extract()
    |> parse()
  end

  defp replace_variables(formula, variables) do
    variables
    |> Map.to_list()
    |> replace_variable(formula)
  end

  defp replace_variable([], formula), do: formula

  defp replace_variable([head | tail], formula) do
    {variable_name, value} = head
    replaced_formula = String.replace(formula, variable_name, value)

    replace_variable(tail, replaced_formula)
  end

  defp parse(%{"left" => left, "right" => right, "parenth" => parenth}) do
    parenthesis =
      parenth
      |> String.trim_leading("(")
      |> String.trim_trailing(")")
      |> extract()
      |> parse()
      |> Runner.run()

    (left <> "#{parenthesis}" <> right)
    |> extract()
    |> parse()
  end

  defp parse(%{"left" => left, "right" => right, "func" => func}) do
    left_arg = parse_argument(left)
    right_arg = parse_argument(right)

    %Node{function: func, left: left_arg, right: right_arg}
  end

  defp extract(formula) do
    formula
    |> String.replace(" -", "-")
    |> maybe_extract(~r"(?<left>.*)(?<parenth>\([^\(\)]*\))(?<right>.*)")
    |> maybe_extract(~r"(?<left>[^+]+)(?<func>\+)(?<right>.*)")
    |> maybe_extract(~r"^(?<left>(\-*[^\-]+)*)(?<func>\-+)(?<right>[^\-]*)$")
    |> maybe_extract(~r"(?<left>[^*]+)(?<func>\*)(?<right>.*)")
    |> maybe_extract(~r"(?<left>.*)(?<func>/)(?<right>[^/]*)")
  end

  defp maybe_extract(formula, pattern) when is_binary(formula) do
    case Regex.named_captures(pattern, formula) do
      nil -> formula
      result -> result
    end
  end

  defp maybe_extract(result, _pattern) when is_map(result), do: result

  defp parse_argument(string) do
    is_function? = contains_any?(string, ["+", "-", "/", "*"])

    if is_function? do
      string
      |> String.trim()
      |> extract()
      |> parse()
    else
      parse_number(string)
    end
  end

  defp parse_number(""), do: %Node{value: 0}

  defp parse_number(string) do
    string
    |> String.trim()
    |> maybe_parse_float()
    |> maybe_parse_integer()
  end

  defp contains_any?(string, list), do: contains_any?(string, list, false)
  defp contains_any?(_, [], return), do: return

  defp contains_any?(string, [head | tail], return),
    do: contains_any?(string, tail, return or String.contains?(string, head))

  defp maybe_parse_float(string) when is_binary(string) do
    %Node{value: String.to_float(string)}
  rescue
    _ -> string
  end

  defp maybe_parse_float(any), do: any

  defp maybe_parse_integer(string) when is_binary(string) do
    %Node{value: String.to_integer(string)}
  rescue
    _ -> string
  end

  defp maybe_parse_integer(any), do: any
end
