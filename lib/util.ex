defmodule Util do
  @moduledoc """
  Documentation for `Util`.
  """

  @doc """

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
