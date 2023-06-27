defmodule Util do
  @moduledoc """
  Documentation for `Util`.
  """

  @spec traverse(any, (any -> bool), (any -> [any])) :: Stream.t()
  @doc """
  Takes three arguments, the first of which is the root element.
  The `is_branch?` function takes an element that could be a branch.
  The `children` function returns the children for a given branch element.
  `children` is called on elements for which `is_branch?` returns `true`.
  Inspired by/copied from Clojure's `tree-seq`.

      iex> data = [{:body, [], [{:ul, [], [{:li, [], "hi"}, {:li, [], "there"}]}]}]
      ...> data
      ...> |> List.first()
      ...> |> Util.traverse(
      ...>   fn
      ...>     {_tag, _attrs, children} when is_list(children) -> true
      ...>     l when is_list(l) -> true
      ...>     _ -> false
      ...>   end,
      ...>   fn
      ...>     {_tag, _attrs, children} -> children end
      ...> )
      ...> |> Enum.to_list()
      [
        {:body, [], [{:ul, [], [{:li, [], "hi"}, {:li, [], "there"}]}]},
        {:ul, [], [{:li, [], "hi"}, {:li, [], "there"}]},
        {:li, [], "hi"},
        {:li, [], "there"}
      ]
  """
  def traverse(root, is_branch?, children) do
    walk = fn node, walker ->
      Stream.concat(
        [node],
        if is_branch?.(node) do
          Stream.flat_map(children.(node), fn n -> walker.(n, walker) end)
        else
          []
        end
      )
    end

    walk.(root, walk)
  end
end
