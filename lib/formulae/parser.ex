defmodule Formulae.Parser do
  alias Formulae.Nodes.{Function, Number}

  def is_valid?(formula) when is_binary(formula) do
    # check for forbidden characters
    # check for trailing or leading '_'
    # check for missing function characters
    not (Regex.match?(~r"[^A-Za-z0-9()+\-*/_ ,.\t\n\r]", formula) or
           Regex.match?(~r"([^A-Za-z]+\_)|(\_[^A-Za-z0-9]+)", formula) or
           Regex.match?(
             ~r"([^\+\-\/\*\s]+\s+[A-Za-z0-9]+)|([A-Za-z0-9]+\s+[^\+\-\/\*]+)",
             formula
           ))
  end

  def is_valid?(_), do: false

  @spec get_variables_list(binary) :: [[binary | {integer, integer}]]
  def get_variables_list(formula) when is_binary(formula) do
    Regex.scan(~r"(?:[A-Za-z][A-Za-z0-9_]*)", formula)
  end

  def run(formula, variables \\ %{}) when is_binary(formula) do
    formula
    |> replace_variables(variables)
    |> String.replace(" ", "")
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

  defp parse(%{"left" => left, "right" => right, "func" => func}) do
    function = parse_function(func)
    left_arg = parse_argument(left)
    right_arg = parse_argument(right)

    %Function{func: function, left: left_arg, right: right_arg}
  end

  defp extract(formula) do

    formula
    # trim encapsulating parenthesis
    |> maybe_trim(~r"^\((?<inside>(?:.*\(+.+\)+.*)|(?:[^\(\)]+))\)$")
    # extract addition
    |> maybe_extract(~r"^(?<left>.+)(?<func>\+)(?<right>[^\(\)]+)$")
    |> maybe_extract(~r"^(?<left>[^\(\)]+)(?<func>\+)(?<right>.+)$")
    |> maybe_extract(~r"^(?<left>\(.+\))(?<func>\+)(?<right>\(.*\))$")
    # extract subtraction
    |> maybe_extract(~r"^(?<left>(?:[^\-]*)|(?:.*))(?<func>\-+)(?<right>[^\(\)\-]+)$")
    |> maybe_extract(~r"^(?<left>[^\(\)\-]+)(?<func>\-+)(?<right>.+)$")
    |> maybe_extract(~r"^(?<left>\(.+\))(?<func>\-+)(?<right>\(.*\))$")
    |> maybe_extract(~r"^(?<left>)(?<func>\-+)(?<right>\(.*\))$")
    |> maybe_extract(~r"^(?<left>[^\-]*)(?<func>\-+)(?<right>(?:\(.*\))|(?:\s*[0-9]))$")
    |> maybe_extract(~r"^(?<left>[^\(\)]+)(?<func>\-+)(?<right>.+)$")
    # extract multiplication
    |> maybe_extract(~r"^(?<left>.+)(?<func>\*)(?<right>[^\(\)]*)$")
    |> maybe_extract(~r"^(?<left>[^\(\)]+)(?<func>\*)(?<right>.*)$")
    |> maybe_extract(~r"^(?<left>\(.+\))(?<func>\*)(?<right>\(.*\))$")
    # extract division
    |> maybe_extract(~r"^(?<left>.+)(?<func>\/)(?<right>[^\(\)]*)$")
    |> maybe_extract(~r"^(?<left>[^\(\)]+)(?<func>\/)(?<right>.*)$")
    |> maybe_extract(~r"^(?<left>\(.+\))(?<func>\/)(?<right>\(.*\))$")
  end

  defp maybe_trim(formula, pattern) do
    case Regex.named_captures(pattern, formula) do
      nil -> formula
      %{"inside" => inside} -> inside
    end
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
      |> extract()
      |> parse()
    else
      parse_number(string)
    end
  end

  defp parse_number(""), do: %Number{value: 0}

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
    %Number{value: String.to_float(string)}
  rescue
    _ -> string
  end

  defp maybe_parse_float(any), do: any

  defp maybe_parse_integer(string) when is_binary(string) do
    %Number{value: String.to_integer(string)}
  rescue
    _ -> string
  end

  defp maybe_parse_integer(any), do: any

  defp parse_function("+"), do: &Kernel.+/2
  defp parse_function("-"), do: &Kernel.-/2
  defp parse_function("/"), do: &Kernel.//2
  defp parse_function("*"), do: &Kernel.*/2

  defp parse_function(string) do
    string
    |> String.length()
    |> Kernel.rem(2)
    |> case do
      0 -> &Kernel.+/2
      1 -> &Kernel.-/2
    end
  end
end
