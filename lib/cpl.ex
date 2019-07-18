defmodule Cpl do
  @moduledoc """
  Documentation for Classical Propositional Logoc.
  """

  defp arity(connective, language) do
    language[:connectives][connective]
  end

  @spec is_formula(any, any) :: boolean
  def is_formula(atom, language) when is_atom(atom) do
    atom in language[:atoms]
  end

  def is_formula([unary_connective, subformula], language) do
    arity(unary_connective, language) == 1 and is_formula(subformula, language)
  end

  def is_formula([left_subformula, binary_connective, right_subformula], language) do
    arity(binary_connective, language) == 2 and is_formula(left_subformula, language) and
      is_formula(right_subformula, language)
  end

  def is_formula(_, _), do: false

  def apply([:t, [:not, x]]) do
    [[:f, x]]
  end

  def apply([:f, [:not, x]]) do
    [[:t, x]]
  end

  def apply([:t, [x, :and, y]]) do
    [[:t, x], [:t, y]]
  end

  def apply([:f, [x, :or, y]]) do
    [[:f, x], [:f, y]]
  end

  def apply([:f, [x, :implies, y]]) do
    [[:t, x], [:f, y]]
  end

  def apply([:f, [_, :and, _]]) do
  end

  def apply([:t, [_, :or, _]]) do
  end

  def apply([:t, [_, :implies, _]]) do
  end

  def apply([:t, x]) when is_atom(x) do
  end

  def apply([:f, x]) when is_atom(x) do
  end

  def apply(_) do
    :error
  end

  def expand_tableau(tableau) do
    tableau
    |> Enum.map(&Cpl.apply/1)
    |> Enum.filter(fn x -> x != nil end)
  end

  def apply_branching_rule([:f, [x, :and, y]]) do
    {[:f, x], [:f, y]}
  end

  def apply_branching_rule([:t, [x, :or, y]]) do
    {[:t, x], [:t, y]}
  end

  def apply_branching_rule([:t, [x, :implies, y]]) do
    {[:f, x], [:t, y]}
  end

  defp my_flatten_aux([[head1, head2] | tail], partial) do
    my_flatten_aux(tail, [head2, head1] ++ partial)
  end

  defp my_flatten_aux([[head] | tail], partial) do
    my_flatten_aux(tail, [head] ++ partial)
  end

  defp my_flatten_aux([], partial) do
    partial
  end

  defp my_flatten(list) do
    Enum.reverse(my_flatten_aux(list, []))
  end

  defp expand_all_aux(tableau, partial_result) do
    temp =
      tableau
      |> expand_tableau()
      |> my_flatten()

    cond do
      temp == [] ->
        partial_result ++ tableau

      true ->
        expand_all_aux(temp, partial_result ++ tableau)
    end
  end

  def expand_all(tableau) do
    expand_all_aux(tableau, [])
  end

  def is_beta([:f, [_, :and, _]]), do: true
  def is_beta([:t, [_, :or, _]]), do: true
  def is_beta([:t, [_, :implies, _]]), do: true
  def is_beta(_), do: false

  def select_betas(list) do
    Enum.filter(list, &is_beta/1)
  end

  def bifurcate(tableau, formula) do
    {left, right} = apply_branching_rule(formula)
    [tableau] ++ [[left]] ++ [[right]]
  end
end
