defmodule FormulaeTest do
  use ExUnit.Case, async: true
  doctest Formulae

  describe "simple math with no unknowns" do
    test "works without whitespaces" do
      assert 3 == Formulae.run("1+2")
      assert -1 == Formulae.run("1-2")
      assert 2 == Formulae.run("1*2")
      assert 0.5 == Formulae.run("1/2")
    end

    test "works with whitespaces" do
      assert 3 == Formulae.run("1 + 2")
      assert -1 == Formulae.run(" 1 - 2 ")
      assert 2 == Formulae.run(" 1*2 ")
      assert 0.5 == Formulae.run("1 /2 ")
    end

    test "works with floats" do
      assert 3 == Formulae.run("1.0 + 2,0")
      assert -1 == Formulae.run(" 1.0 - 2 ")
      assert 2 == Formulae.run(" 1*2,0 ")
    end

    test "works with multiple additions" do
      assert 3 == Formulae.run("1 + 2")
      assert 6 == Formulae.run("1 + 2 + 3")
      assert 10 == Formulae.run("1 + 2 + 3 + 4")
      assert 15 == Formulae.run("1 + 2 + 3 + 4 + 5")
    end

    test "works with multiple subtractions" do
      assert -1 == Formulae.run("1 - 2")
      assert -4 == Formulae.run("1 - 2 - 3")
      assert -8 == Formulae.run("1 - 2 - 3 - 4")
      assert -13 == Formulae.run("1 - 2 - 3 - 4 - 5")
    end

    test "works with multiple multiplications" do
      assert 2 == Formulae.run("1 * 2")
      assert 6 == Formulae.run("1 * 2 * 3")
      assert 24 == Formulae.run("1 * 2 * 3 * 4")
      assert 120 == Formulae.run("1 * 2 * 3 * 4 * 5")
    end

    test "works with multiple divisions" do
      assert 1 == Formulae.run("2 / 2")
      assert 0.5 == Formulae.run("2 / 2 / 2")
      assert 0.25 == Formulae.run("2 / 2 / 2 / 2")
      assert 0.125 == Formulae.run("2 / 2 / 2 / 2 / 2")
    end

    test "works with additions and subtractions combined" do
      assert 0 == Formulae.run("1 + 2 - 3")
      assert 4 == Formulae.run("1 + 2 - 3 + 4")
      assert -1 == Formulae.run("1 + 2 - 3 + 4 - 5")
    end

    test "works with multiplications and divisions combined" do
      assert 0.5 == Formulae.run("1 * 2 / 4")
      assert 2 == Formulae.run("1 * 2 / 4 * 4")
      assert 1 == Formulae.run("1 * 2 / 4 * 5 / 2.5")
    end

    test "works with additions and multiplication combined" do
      assert 5 == Formulae.run("1 * 2 + 3")
      assert 7 == Formulae.run("1 + 2 * 3")
      assert 7.8 == Formulae.run("1 + 2 * 3 + 4 / 5")
    end

    test "works with simple parenthesis" do
      assert 9 == Formulae.run("(1 + 2) * 3")
      assert 3.8 == Formulae.run("1 + 2 * (3 + 4) / 5")
      assert 5.6 == Formulae.run("(2 + 2) * (3 + 4) / 5")
    end

    test "works with nested parenthesis" do
      assert 357 == Formulae.run("(((2 + 3) * (4 + 5)) + 6) * 7")
    end
  end

  describe "math with unknowns" do
    test "works with simple variables" do
      variables_map = %{"one" => "1", "two" => "2", "three" => "3", "four" => "4"}

      assert 5 == Formulae.run("one * two + three", variables_map)
      assert 14 == Formulae.run("one * two + three * four", variables_map)
    end
  end

  describe "regressions" do
    test "negative numers" do
      variables_map = %{"one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5"}

      assert 50 == Formulae.run("((one + two) + (three + four)) * five", variables_map)
      assert -20 == Formulae.run("((one + two) - (three + four)) * five", variables_map)
      assert 20 == Formulae.run("((one + two) - (three - four)) * five", variables_map)
      assert -3 == Formulae.run("- (one + two)", variables_map)
      assert -3 == Formulae.run("-one-two", variables_map)
      assert -3 == Formulae.run("-(one-(-two))", variables_map)
      assert -3 == Formulae.run("-(one-- -(- - -two))", variables_map)
    end
  end
end
