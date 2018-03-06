defmodule DexGraph.Gremlin.LowLevel do
  @moduledoc """
  Low level functions
  """
  require Logger
  import DexGraph
  alias DexGraph.Gremlin.LowLevel
  @doc """
  Sendet ein dgraph mutate zum server
  """
  # def mutate_with_commit(a_query) do
  #   #  Logger.info fn -> "💡 a_query #{inspect a_query}" end
  #   headers = [{"X-Dgraph-CommitNow", "true"}]

  #   post_response =
  #     HTTPoison.post("#{Application.get_env(:dexgraph, :server)}/mutate", a_query, headers)

  #     DexGraph.get_data_from_response(post_response)
  # end

  @doc """
  Creates the nquad and send it as mutaion request with a commit
  """
  def mutate_vertex(graph, predicate, object) do
    #mutate_with_commit(~s(_:identifier <#{predicate}> "#{object}" .))
    mutate_with_commit(~s({set{_:identifier <#{predicate}> "#{object}" .}}))
  end

  @doc """
  Creates the nquad and send it as mutaion request with a commit
  """
  def mutate_vertex(graph, subject_uid, predicate, object) do
    #mutate_with_commit(~s(<#{subject_uid}> <#{predicate}> "#{object}" .))
    mutate_with_commit(~s({set{<#{subject_uid}> <#{predicate}> "#{object}" .}}))
  end

  @doc """
  Creates the nquad and send it as mutaion request with a commit
  """
  def mutate_edge(graph, subject_uid, predicate, object_uid) do
    mutate_with_commit(~s({set{<#{subject_uid}> <#{predicate}> <#{object_uid}> .}}))
  end

@doc """

  """
  def query_vertex(graph, predicate, object, display) do
    channel = graph.channel
    if display != "expand(_all_)" do
      display = "vertex_type " <> display
    end
    query = """
    { vertices(func: anyofterms(#{predicate}, \"#{object}\")) { #{display} } }
    """

    request = ExDgraph.Api.Request.new(query: query)
    {:ok, msg} = channel |> ExDgraph.Api.Dgraph.Stub.query(request)
    decoded_json = Poison.decode!(msg.json)
    vertices = decoded_json["vertices"]
    Logger.info(fn -> "💡 vertices: #{inspect vertices}" end)
    map =
      Enum.map(vertices, fn vertex_map ->
        vertex = for {key, val} <- vertex_map, into: %{}, do: {String.to_atom(key), val}
        struct_type = String.to_existing_atom("Elixir." <> vertex.vertex_type)
        struct(struct_type, vertex)
      end)

    map
  end
  def query_vertex(graph, predicate, object) do
    query_vertex(graph, predicate, object, "expand(_all_)")
  end
end
