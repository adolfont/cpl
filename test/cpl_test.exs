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

  test "All NOT rules" do
    assert apply([:t, [:not, :p]]) == [[:f, :p]]
    assert apply([:f, [:not, :p]]) == [[:t, :p]]
  end

  test "linear binary rules" do
    assert apply([:t, [:p, :and, :q]]) == [[:t, :p], [:t, :q]]
    assert apply([:f, [:p, :or, :q]]) == [[:f, :p], [:f, :q]]
    assert apply([:f, [:p, :implies, :q]]) == [[:t, :p], [:f, :q]]
  end

  test "atomic formulas" do
    assert apply([:t, :p]) == nil
    assert apply([:f, :q]) == nil
  end

  test "Error" do
    assert apply(:t) == :error
    assert apply([:y, :q]) == :error
  end

  test "Expand Tableau 1" do
    tableau = [
      [:t, :a],
      [:t, [:a, :implies, :b]],
      [:f, :b]
    ]

    assert expand_tableau(tableau) == []
  end

  test "Expand Tableau 2" do
    tableau = [
      [:t, [:a, :and, :b]],
      [:f, [:a, :implies, :b]],
      [:f, [:a, :or, :b]],
      [:t, [:not, :a]],
      [:f, [:not, :a]]
    ]

    assert expand_tableau(tableau) == [
             [[:t, :a], [:t, :b]],
             [[:t, :a], [:f, :b]],
             [[:f, :a], [:f, :b]],
             [[:f, :a]],
             [[:t, :a]]
           ]
  end

  test "Expand Tableau 3" do
    tableau = [
      [:t, [:not, [:not, :a]]]
    ]

    assert expand_tableau(tableau) == [
             [[:f, [:not, :a]]]
           ]

    [x] = expand_tableau(tableau)
    assert expand_tableau(x) == [[[:t, :a]]]
  end

  test "Expand all" do
    tableau = [
      [:t, [:not, [:not, :a]]],
      [:t, [:b, :and, :c]]
    ]

    assert MapSet.new(expand_all(tableau)) ==
             MapSet.new([
               [:t, [:not, [:not, :a]]],
               [:f, [:not, :a]],
               [:t, :a],
               [:t, [:b, :and, :c]],
               [:t, :b],
               [:t, :c]
             ])
  end

  test "branching rules" do
    assert apply_branching_rule([:f, [:p, :and, :q]]) == {[:f, :p], [:f, :q]}
    assert apply_branching_rule([:t, [:p, :or, :q]]) == {[:t, :p], [:t, :q]}
    assert apply_branching_rule([:t, [:p, :implies, :q]]) == {[:f, :p], [:t, :q]}
  end
end
