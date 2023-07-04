defmodule Util do
  @moduledoc """
  Documentation for `Util`.
  """

  @spec tree_stream(any, (any -> bool), (any -> Enumerable.t())) :: Enumerable.t()
  @doc """
  Traverses and returns a `Stream` of the individual nodes of a tree structure.
  Takes three arguments, the first of which is the root element.
  The `is_branch?` function takes an element that could be a branch.
  The `children` function returns the children for a given branch element.
  `children` is called on elements for which `is_branch?` returns `true`.
  Inspired by/copied from Clojure's `tree-seq`.

      iex> # With a list as the root:
      ...> data = [{:body, [], [{:ul, [], [{:li, [], "hi"}, {:li, [], "there"}]}]}]
      ...> data
      ...> |> Util.tree_stream(
      ...>   fn
      ...>     l when is_list(l) -> true
      ...>     {_tag, _attrs, children} when is_list(children) -> true
      ...>     _ -> false
      ...>   end,
      ...>   fn
      ...>     l when is_list(l) -> l
      ...>     {_tag, _attrs, children} -> children
      ...>   end
      ...> )
      ...> |> Enum.to_list()
      [
        [{:body, [], [{:ul, [], [{:li, [], "hi"}, {:li, [], "there"}]}]}],
        {:body, [], [{:ul, [], [{:li, [], "hi"}, {:li, [], "there"}]}]},
        {:ul, [], [{:li, [], "hi"}, {:li, [], "there"}]},
        {:li, [], "hi"},
        {:li, [], "there"}
      ]

      iex> # With a map as the root:
      ...> data = %{a: [1, %{b: "hi", c: %{d: 999}}, 2], x: "terminal"}
      ...> data
      ...> |> Util.tree_stream(
      ...>   fn
      ...>     {_k, v} when is_list(v) or is_map(v) -> true
      ...>     m when is_map(m) -> true
      ...>     _ -> false
      ...>   end,
      ...>   fn
      ...>     {_k, v} -> v
      ...>     m when is_map(m) -> Enum.into(m, [])
      ...>   end
      ...> )
      ...> |> Enum.to_list()
      [
        %{
          a: [
            1,
            %{
              b: "hi",
              c: %{d: 999}
            },
            2
          ],
          x: "terminal"
        },
        {:a, [1, %{c: %{d: 999}, b: "hi"}, 2]},
        1,
        %{b: "hi", c: %{d: 999}},
        {:c, %{d: 999}},
        {:d, 999},
        {:b, "hi"},
        2,
        {:x, "terminal"}
      ]
  """
  def tree_stream(root, is_branch?, children) do
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
