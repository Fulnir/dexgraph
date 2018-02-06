defmodule DexGraph do
  @moduledoc """
  
  ## A simple http based driver for dgraph.
  
  #### dgraph is located at [dgraph.io](http://www.dgraph.io)
  
  ### Constants
  
  * `@unique_predicates` All unique predicates are defined in this constant.
  Used in `is_unique_predicate?()`
  
  Copyright © 2018 Edwin Buehler. All rights reserved.
  """

  require Logger

  # All unique predicates are defined in `@unique_predicates`.
  # Used in `is_unique_predicate?()``
  @unique_predicates [:id]

  # @the_schema "name: string @index(exact, term) .\n  id: string @index(exact) .\n  comment: string .\n   namespace: uid .\n    inherit_from: uid .\n   type_of: uid .\n    user_id: uid .\n"  

  @doc """
  This function is used to setup the test data for the
  unit tests. Called in `DexGraphTest.setup_all()`
  """
  def write_testing_data(test_data) do
    mutate_with_commit(test_data)
  end

  @doc """
  Add or modify the database schema.

  dgraph docs: [Adding or Modifying Schema](https://docs.dgraph.io/query-language/#adding-or-modifying-schema)
  """
  def write_schema(schema) do
    alter(schema)
  end

  @doc """
  Returns the query result.

  dgraph docs: [Query Language](https://docs.dgraph.io/query-language/)

  ## Examples

      iex> DexGraph.query("schema(pred: [name]) {index}")
      {:ok, %{"schema" => [%{"index" => true, "predicate" => "name"}]}}

  """
  @spec query(String) :: String
  def query(a_query) do
    post_response = HTTPoison.post("#{Application.get_env(:dexgraph, :server)}/query", a_query)
    get_data_from_response(post_response)
  end

  @doc """
  Sendet eine dgraph query zum server
  """
  def alter(a_query) do
    post_response = HTTPoison.post("#{Application.get_env(:dexgraph, :server)}/alter", a_query)
    get_data_from_response(post_response)
  end

  @doc """
  Sendet ein dgraph mutate zum server
  """
  def mutate_with_commit(a_query) do
    headers = [{"X-Dgraph-CommitNow", "true"}]
    post_response = HTTPoison.post("#{Application.get_env(:dexgraph, :server)}/mutate", a_query, headers)
    get_data_from_response(post_response)
  end
 
  # Returns: {:ok, data} or {:error, error}
  @spec get_data_from_response(Tuple) :: Tuple
  defp get_data_from_response({:ok, response}) do
    case Poison.decode(response.body) do
      # IO.inspect response
      # TODO: Refactoring for Error Handling.
      {:ok, body} ->
        #
        # Logger.error "query #{inspect body}"
        case data = body["data"] do
          nil ->
            #Logger.warn(List.first(body["errors"])["message"])
            {:error, List.first(body["errors"])["message"]}

          _ ->
            {:ok, data}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp get_data_from_response({:error, error}) do
    {:error, error}
  end

  @doc """
  Returns the dgraph schema query result.

  dgraph query `schema {}`

  dgraph docs:[Querying Schema](https://docs.dgraph.io/query-language/#querying-schema)

  """
  @spec query_schema :: String
  def query_schema, do: query("schema {}")

  @doc """
  Returns a node for the given predicate and object.

  If no node found, it returns `{:not_found, %{"find_node" => []}}`
  
  ## Examples

      iex> DexGraph.query_node("name", "Object Name")
      {:not_found, %{"find_node" => []}}

  """
  @spec query_node(String, String) :: String
  def query_node(predicate, object) do
    case query("{
            find_node(func: eq(#{predicate}, \"#{object}\")) {
                uid
                #{predicate}
            }
          }") do
      {:ok, response} ->
        #Logger.warn("Response: #{inspect(response)}")

        case List.first(response["find_node"]) do
          nil ->
            {:not_found, response}

          result ->
            {:ok, result}
        end

      {:error, error} ->
        {:error, error}

      _ ->
        {:nothing}
    end
  end

  @doc """
  Returns a new created node. Only one predicate with object needed.

  ## Examples

      iex> {:ok, node} = DexGraph.mutate_node("name", "Edwin Bühler")
      ...>node["code"]
      "Success"

  """
  @spec mutate_node(String, String) :: Struct
  def mutate_node(predicate, object) do
    # Ist das predicate unique? Wenn ja überprüfen ob schon
    # ein Wert für dieses Predicate existiert.
    if is_unique_predicate?(predicate) do
      mutate_with_commit(~s({set{_:identifier <#{predicate}> #{object} .}}))
    else
      mutate_with_commit(~s({set{_:identifier <#{predicate}> "#{object}" .}}))
    end
  end

  @doc """
  Returns a new created node. A predicate with object and a Subjekt-uid are needed.

  ## Examples

      iex> {:ok, node} = DexGraph.mutate_node("0x1be", "name", "Edwin Bühler")
      ...>node["code"]
      "Success"

  """
  def mutate_node(subject_uid, predicate, object) do
    # Ist das predicate unique? Wenn ja überprüfen ob schon
    # ein Wert für dieses Predicate existiert.
    if is_unique_predicate?(predicate) do
      mutate_with_commit(~s({set{<#{subject_uid}> <#{predicate}> #{object} .}}))
    else
      mutate_with_commit(~s({set{<#{subject_uid}> <#{predicate}> "#{object}" .}}))
    end
  end

  @doc """
  Returns a new node. 

  """
  @spec mutate_node(Map) :: Map
  def mutate_node(node_struct) do
    # Den Struct auflösen
    content = node_struct |> Enum.into(Map.new)

    # Logger.warn "node_struct #{inspect content}"
    mutate_string = "{\n  set {\n"
    lambda =  fn 
        ({predicate_key, object_value}, mutate_string) when is_atom(object_value) ->
      #{:ok, node} = mutate_node("id", "EdwinBühler")
      #identifier = node["uids"]["identifier"]    
      #{:ok, _} = mutate_node(identifier, "id", "EdwinBühler")

      if is_unique_predicate?(predicate_key) do
        #mutate_with_commit(~s({set{_:identifier <#{predicate}> #{object} .}}))
      else
        #mutate_with_commit(~s({set{_:identifier <#{predicate}> "#{object}" .}}))
       #mutate_string <> object_value
      end
      mutate_string
        {predicate_key, object_value}, mutate_string ->
          mutate_string = mutate_string <> "    _:identifier"
          mutate_string = mutate_string <> " \<" <> Atom.to_string(predicate_key) <> "\>"
          mutate_string = mutate_string <> " \"" <> object_value <> "\" . \n"
          mutate_string
    end
    mutate_string = Enum.reduce(content, mutate_string, lambda)
    mutate_string = mutate_string <> "  }\n}"
    Logger.debug "💡 mutate_string #{mutate_string}"
    mutate_with_commit(mutate_string)
  end

    @doc """
  Returns a new node. 

  """
  @spec mutate_node(Struct) :: Struct
  def mutate_node_from_struct(node_struct) do
    Logger.debug " "
    # Match the struct name
    %{__struct__: struct_name} = node_struct
    Logger.debug "💡 struct_name #{inspect struct_name}"
    # Transform struct to map
    map_from_struct = Map.from_struct(node_struct)
    Logger.debug "💡 map_from_struct #{inspect map_from_struct}"

# IO.puts "💡 node_struct #{inspect node_struct}"
    
    #IO.puts "is_struct #{inspect is_struct(node_struct)}"
    
    content = map_from_struct # map_from_struct |> Enum.into(Map.new)
 #   IO.puts "💡 content #{inspect content}"
    # Logger.warn "node_struct #{inspect content}"
    mutate_string = "{\n  set {\n"
    lambda =  fn 
        ({predicate_key, object_value}, mutate_string) when is_atom(object_value) ->
      #{:ok, node} = mutate_node("id", "EdwinBühler")
      #identifier = node["uids"]["identifier"]    
      #{:ok, _} = mutate_node(identifier, "id", "EdwinBühler")

      if is_unique_predicate?(predicate_key) do
        #mutate_with_commit(~s({set{_:identifier <#{predicate}> #{object} .}}))
      else
        #mutate_with_commit(~s({set{_:identifier <#{predicate}> "#{object}" .}}))
       #mutate_string <> object_value
      end
      mutate_string
        {predicate_key, object_value}, mutate_string ->
          mutate_string = mutate_string <> "    _:identifier"
          mutate_string = mutate_string <> " \<" <> Atom.to_string(predicate_key) <> "\>"
          mutate_string = mutate_string <> " \"" <> object_value <> "\" . \n"
          mutate_string
    end
    mutate_string = Enum.reduce(content, mutate_string, lambda)
    mutate_string = mutate_string <> "  }\n}"
    Logger.debug "💡 mutate_string #{mutate_string}"
    mutate_with_commit(mutate_string)
  end

  @doc """
  This function check if the given predicate is unique. If so, then only one edge
  is allowed per node with this predicate. All unique predicates
  are defined in `@unique_predicates`.

  The predicate <id> is mostly unique. The predicate <name> not

  Sample list: `@unique_predicates [:id]`
  
  ## Examples

      iex> DexGraph.is_unique_predicate?(:id)
      true

  """
  def is_unique_predicate?(predicate) do
    Enum.member?(@unique_predicates, predicate)
  end
end
