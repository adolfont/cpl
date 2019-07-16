defmodule CplTest do
  use ExUnit.Case
  doctest Cpl
  import Cpl

  @lp %{
    atoms: MapSet.new([:p, :q, :r, :s]),
    connectives: %{not: 1, and: 2, or: 2, implies: 2}
  }

  test ":p, :q, :r are well-formed formulas" do
    assert is_formula(:p, @lp)
    assert is_formula(:q, @lp)
    assert is_formula(:r, @lp)
  end

  test ":x is NOT a well-formed formula" do
    refute is_formula(:x, @lp)
  end

  test "[:not, :p] is a  well-formed formula" do
    assert is_formula([:not, :p], @lp)
  end

  test "[:not, :p, :q] is NOT a well-formed formula" do
    refute is_formula([:not, :p, :q], @lp)
  end

  test "[:p, :and, :p] is a  well-formed formula" do
    assert is_formula([:p, :and, :q], @lp)
  end

  test "[:not, [ [ [:p, :implies, :q], :and, :r], :or, :s]] is a well-formed formula" do
    assert is_formula([:not, [[[:p, :implies, :q], :and, :r], :or, :s]], @lp)
  end
end
