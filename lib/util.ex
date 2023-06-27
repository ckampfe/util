defmodule Util do
  @moduledoc """
  Documentation for `Util`.
  """

  @doc """
  example.nodes
  |> List.first()
  |> Traverser.traverse(fn
  {_tag, _attrs, children} when is_list(children) -> true
  l when is_list(l) -> true
  _ -> false end,
  fn
    {_tag, _attrs, children} ->
    children
  end
  )
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
