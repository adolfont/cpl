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
end
