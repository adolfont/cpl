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

  test "Expand all 1" do
    tableau = [
      [:t, [:not, [:not, :a]]],
      [:t, [:b, :and, :c]]
    ]

    assert expand_all(tableau) ==
             [
               [:t, [:not, [:not, :a]]],
               [:t, [:b, :and, :c]],
               [:f, [:not, :a]],
               [:t, :b],
               [:t, :c],
               [:t, :a]
             ]
  end

  test "Expand all 2" do
    tableau = [
      [:t, [:not, [:not, :a]]],
      [:f, [:d, :and, :e]],
      [:t, [:b, :and, :c]]
    ]

    assert expand_all(tableau) ==
             [
               [:t, [:not, [:not, :a]]],
               [:f, [:d, :and, :e]],
               [:t, [:b, :and, :c]],
               [:f, [:not, :a]],
               [:t, :b],
               [:t, :c],
               [:t, :a]
             ]
  end

  test "Select betas 1" do
    tableau = [
      [:t, [:not, [:not, :a]]],
      [:f, [:d, :and, :e]],
      [:t, [:b, :and, :c]]
    ]

    assert select_betas(tableau) == [[:f, [:d, :and, :e]]]
  end

  test "Select betas 2" do
    tableau = [
      [:t, [:not, [:a, :and, :g]]],
      [:f, [:d, :and, :e]],
      [:t, [:b, :and, :c]]
    ]

    assert select_betas(expand_all(tableau)) == [[:f, [:d, :and, :e]], [:f, [:a, :and, :g]]]
  end

  test "Bifurcate 1" do
    tableau = [
      [:t, [:a, :or, :b]],
      [:f, :a]
    ]

    result_tableau = [
      tableau,
      [[:t, :a]],
      [[:t, :b]]
    ]

    [first | _] = select_betas(tableau)

    assert bifurcate(tableau, first) ==
             result_tableau
  end

  test "Bifurcate 2" do
    tableau = [
      [:t, [[:a, :or, :b], :or, :c]],
      [:f, :c]
    ]

    result_tableau = [
      tableau,
      [[:t, [:a, :or, :b]]],
      [[:t, :c]]
    ]

    [first | _] = select_betas(tableau)

    assert bifurcate(tableau, first) ==
             result_tableau
  end

  test "Bifurcate 3" do
    tableau = [
      [:t, [[:a, :or, :b], :or, :c]],
      [:f, :c]
    ]

    result_tableau = [
      tableau,
      [[:t, [:a, :or, :b]]],
      [[:t, :c]]
    ]

    [root, left, right] = result_tableau

    [first | _] = select_betas(left)

    assert [root, bifurcate(left, first), right] ==
             [
               [[:t, [[:a, :or, :b], :or, :c]], [:f, :c]],
               [[[:t, [:a, :or, :b]]], [[:t, :a]], [[:t, :b]]],
               [[:t, :c]]
             ]
  end

  test "branching rules" do
    assert apply_branching_rule([:f, [:p, :and, :q]]) == {[:f, :p], [:f, :q]}
    assert apply_branching_rule([:t, [:p, :or, :q]]) == {[:t, :p], [:t, :q]}
    assert apply_branching_rule([:t, [:p, :implies, :q]]) == {[:f, :p], [:t, :q]}
  end
end
