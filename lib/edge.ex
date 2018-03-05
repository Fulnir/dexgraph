defmodule DexGraph.Gremlin.Edge do
  @moduledoc """
  And edge for gremlin
  """
  require Logger
  alias DexGraph.Gremlin.Edge
  alias DexGraph.Gremlin.Graph
  alias DexGraph.Gremlin.Vertex
  @doc """
  The edge properties.
  Reserved for cache and other
  """
  defstruct graph: Graph,
            predicate: String,
            from: Vertex,
            to: Vertex

  @doc """
  Creates a new graph
  """
  def new(the_graph, predicate) do
    %Edge{graph: the_graph, predicate: predicate}
  end
end
