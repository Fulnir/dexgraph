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
    #  Logger.info fn -> "💡 a_query #{inspect a_query}" end
    headers = [{"X-Dgraph-CommitNow", "true"}]

    post_response =
      HTTPoison.post("#{Application.get_env(:dexgraph, :server)}/mutate", a_query, headers)

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
            # Logger.warn(List.first(body["errors"])["message"])
            {:error, List.first(body["errors"])["message"]}

          _ ->
            #          Logger.warn fn -> "💡 data #{inspect data}" end
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
  def query_node(predicate, object, node_values \\ []) do
    lambda = fn other_predicate, other_value_predicates ->
      other_value_predicates = other_value_predicates <> " " <> other_predicate
    end

    other_value_predicates = ""
    other_value_predicates = Enum.reduce(node_values, other_value_predicates, lambda)
    query_string = "{
      find_node(func: eq(#{predicate}, \"#{object}\")) {
          uid #{predicate}#{other_value_predicates}
      }
    }"
    #    Logger.error("Response: #{inspect(query_string)}")
    case query(query_string) do
      {:ok, response} ->
        #        Logger.warn("Response: #{inspect(response)}")
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
  Returns a new node. {:ok, node}

  """
  @spec mutate_node(Map) :: Map
  def mutate_node(map_from_struct) do
    mutate_string = "{\n  set {\n"

    lambda = fn
      {predicate_key, object_value}, mutate_string
      when is_atom(object_value) and predicate_key == :dex_node_type ->
        #       Logger.debug fn -> "💡 dex_node_type is_atom #{inspect object_value}" end
        if is_unique_predicate?(predicate_key) do
          # mutate_with_commit(~s({set{_:identifier <#{predicate}> #{object} .}}))
        else
          # mutate_with_commit(~s({set{_:identifier <#{predicate}> "#{object}" .}}))
          # mutate_string <> object_value
        end

        mutate_string

      {predicate_key, object_value}, mutate_string
      when is_atom(object_value) and predicate_key != :dex_node_type ->
        # Logger.debug(fn -> "💡 #{inspect(predicate_key)} is_atom #{inspect(object_value)}" end)
        mutate_string

      {predicate_key, object_value}, mutate_string
      when is_list(object_value) ->
        #            Logger.debug fn -> "💡  #{inspect object_value}" end
        mutate_string

      {predicate_key, object_value}, mutate_string ->
        object_value =
          if is_integer(object_value) do
            " \"" <> Integer.to_string(object_value) <> "\""
          else
            " \"" <> object_value <> "\""
          end

        mutate_string =
          mutate_string <>
            "    _:identifier" <>
            " \<" <> Atom.to_string(predicate_key) <> "\>" <> object_value <> " . \n"

        #Logger.debug(fn -> "💡 mutate_string #{inspect(mutate_string)}" end)
        mutate_string
    end

    #   Logger.debug fn -> "💡 mutate_string #{inspect mutate_string}" end
    mutate_string = Enum.reduce(map_from_struct, mutate_string, lambda)
    mutate_string = mutate_string <> "  }\n}"
    mutate_with_commit(mutate_string)
  end

  @doc """
  Create first a map of the struct and add the struct_name as
  :dex_node_type value to the map

  Returns a new node. {:ok, node}

  Returns {:error, "The value is not a struct"} if
  node_struct is not a struct
  """
  @spec mutate_node(Struct) :: Struct
  def mutate_node_from_struct(node_struct) do
    case node_struct do
      %{__struct__: struct_name} ->
        %{__struct__: struct_name} = node_struct
        map_from_struct = Map.from_struct(node_struct)
        map_from_struct = Map.put(map_from_struct, :dex_node_type, struct_name)
        mutate_node(map_from_struct)

      _ ->
        # Or: mutate_node(node_struct) But waht is with :dex_node_type
        {:error, "The value is not a struct"}
    end
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
