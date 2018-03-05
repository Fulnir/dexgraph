defmodule DexGraphTest do
  @moduledoc """
  
  Copyright © 2018 Edwin Buehler. All rights reserved.
  """
  use ExUnit.Case
  doctest DexGraph

  import DexGraph
  # import Person
  alias DexGraph.Gremlin.Person
  require Logger

  @testing_schema "id: string @index(exact).
  name: string @index(exact, term) @count .
  age: int @index(int) .
  alchemist: bool .
  friend: uid @count .
  dob: dateTime .
  location: geo @index(geo) .
  occupations: [string] @index(term) ."

  # Der Tokenizer funktioniert nicht für alle Sprachen.
  # Deshalb im Test term für das Schema benutzen.
  @testing_data ~s({
    set {
      _:michael <name> "Michael" .
      _:michael <age> "39" .
      _:michael <friend> _:amit .
      _:michael <friend> _:sarah .
      _:michael <friend> _:sang .
      _:michael <friend> _:catalina .
      _:michael <friend> _:artyom .
      _:michael <owns_pet> _:rammy .
      
      _:amit <name> "अमित"@hi .
      _:amit <name> "অমিত"@bn .
      _:amit <name> "Amit"@en .
      _:amit <age> "35" .
      _:amit <friend> _:michael .
      _:amit <friend> _:sang .
      _:amit <friend> _:artyom .
      
      _:luke <name> "Luke"@en .
      _:luke <name> "Łukasz"@pl .
      _:luke <age> "77" .
      
      _:artyom <name> "Артём"@ru .
      _:artyom <name> "Artyom"@en .
      _:artyom <age> "35" .
      
      _:sarah <name> "Sarah" .
      _:sarah <age> "55" .
      
      _:sang <name> "상현"@ko .
      _:sang <name> "Sang Hyun"@en .
      _:sang <age> "24" .
      _:sang <friend> _:amit .
      _:sang <friend> _:catalina .
      _:sang <friend> _:hyung .
      _:sang <owns_pet> _:goldie .
      
      _:hyung <name> "형신"@ko .
      _:hyung <name> "Hyung Sin"@en .
      _:hyung <friend> _:sang .
      
      _:catalina <name> "Catalina" .
      _:catalina <age> "19" .
      _:catalina <friend> _:sang .
      _:catalina <owns_pet> _:perro .
      
      _:rammy <name> "Rammy the sheep" .
      
      _:goldie <name> "Goldie" .
      
      _:perro <name> "Perro" .
    }
  }          
  )

  @doc """
  Defines a callback to be run before all tests in a case.
  """
  setup_all do
    IO.puts("🛡 💡 DexGraph setup all: #{Application.get_env(:dexgraph, :server)}")
    # Komplette Datenbank löschen
    IO.puts "🛡 💡 Drop dgraph DB"
    alter("{\"drop_all\": true}")
    # Schema
    IO.puts "🛡 💡 Write schema dgraph DB"
    write_schema(@testing_schema)
    # Daten
    IO.puts "🛡 💡 Write test data dgraph DB"
    _ = write_testing_data(@testing_data)
    :ok
  end
  @doc """
  Defines a callback to be run before each test in a case.
  """
  setup do
    #IO.puts("DexGraph setup all: #{Application.get_env(:dexgraph, :server)}")
    # Komplette Datenbank löschen
    # Logger.info fn -> "💡 Drop dgraph DB" end
    # alter("{\"drop_all\": true}")
    # # Wait until work is done
    # Process.sleep(200)
    # # Schema
    # write_schema(@testing_schema)
    # # Wait until work is done
    # Process.sleep(200)
    # # Daten
    # _ = write_testing_data(@testing_data)
    # Wait until work is done
    #Process.sleep(100)
    :ok
  end

  test "Query unknown node" do
    {result_atom, _} = query_node("name", "test_dummy")
    assert :not_found == result_atom
  end

  test "Is the predicate unique?" do
    assert true == is_unique_predicate?(:id)
    assert false == is_unique_predicate?(:friend)
  end

  test "Query node" do
    {:ok, node} = query_node("name", "Michael")
    assert "Michael" == node["name"]
  end

  test "Query 'schema {}'" do
    _ = query_schema()
  end

  test "Add node" do
    {:ok, _} = mutate_node("name", "Bugs Bunny")
    {:ok, node} = query_node("name", "Bugs Bunny")
    assert "Bugs Bunny" == node["name"]
    {:ok, node} = mutate_node("id", "Duffy")
    identifier = node["uids"]["identifier"]
    {:ok, node} = query_node("id", "Duffy")
    {:ok, _} = mutate_node(identifier, "id", "Duffy")
    {:ok, node} = query_node("name", "Bugs Bunny")
    assert "Bugs Bunny" == node["name"]
    {:ok, node} = query_node("id", "Duffy")
    assert identifier == node["uid"]
  end

  test "Add node as map" do
    {:ok, node} = mutate_node(%{dex_node_type: :person, name: "Puma", address: "Wassenberg"})
    assert "Success" == node["code"]
  end

  describe "Dexgraph" do
    test "Create a map and mutate to db" do
      person = %{
        dex_node_type: :person,
        person_id: "Reimund",
        name: "Reimund",
        alchemist: false,
        gender: :female,
        age: 991
      }

      assert "Reimund" == person.person_id
      assert false == person.alchemist
      assert 991 == person.age
      assert :female == person.gender
      {:ok, node} = mutate_node(person)
      assert "Success" == node["code"]
      {:ok, node} = query_node("name", "Reimund")
      assert "Reimund" == node["name"]
    end

    test "Create a person and mutate to db" do
      # IO.puts  "Create a primitive thing" gender: :male, ,  age: 99
      person = %Person{person_id: "Edwin", name: "Ed", alchemist: true, gender: :male, age: 999}
      assert "Edwin" == person.person_id
      assert true == person.alchemist
      assert :male == person.gender
      assert 999 == person.age
      # thing_map = Map.from_struct(thing)
      # IO.puts "Add thing as struct #{inspect thing_map}"
      {:ok, node} = mutate_node_from_struct(person)
      #    Logger.debug fn -> "💡 node #{node["uids"]["identifier"]}" end
      assert "Success" == node["code"]
      {:ok, node} = query_node("name", "Ed")
      assert "Ed" == node["name"]
    end

    test "Create a map and use mutate_node_from_struct" do
      person = %{person_id: "Joe", name: "Joe", alchemist: true, age: 9999}
      {:error, message} = mutate_node_from_struct(person)
      assert "The value is not a struct" == message
    end

    test "Find person and return all values" do
      person = %Person{person_id: "EdwinBuehler", name: "Ede", alchemist: "true", age: 99}
      assert "EdwinBuehler" == person.person_id
      {:ok, node} = mutate_node_from_struct(person)
      {:ok, node} = query_node("name", "Ede", ["age", "alchemist", "person_id"])
      assert "Ede" == node["name"]
      assert "EdwinBuehler" == node["person_id"]
      assert true == node["alchemist"]
      assert "true" != node["alchemist"]
      assert 99 == node["age"]
      {:ok, node} = query_node("age", 99, ["name", "alchemist", "person_id"])
      #Logger.debug fn -> "💡 node #{inspect node}" end
      assert 99 == node["age"]
      assert "Ede" == node["name"]
    end
  end

  describe "Friends" do
    test "Create and add friends" do
      friend1 = %Person{person_id: "friend1", name: "friend1"}
      {:ok, node} = mutate_node_from_struct(friend1)
      {:ok, node} = query_node("name", "friend1")
      assert "friend1" == node["name"]
      friend2 = %Person{person_id: "friend2", name: "friend2"}
      friend = %Person{person_id: "friend", name: "friend", friend: [friend1, friend2]}
      {:ok, node} = mutate_node_from_struct(friend)
      {:ok, node} = query_node("name", "friend", ["friend {expand(_all_)}"])
      assert "friend" == node["name"]

      Logger.debug fn -> "💡 node############# #{inspect node}" end
    end
    test "Query friends" do
      {:ok, node} = query_node("name", "Michael", ["friend {name}", "owns_pet"])
      assert "Michael" == node["name"]
      #Logger.debug fn -> "💡 node #{inspect node}" end
    end
    test "Add friends" do
      {:ok, node} = query_node("name", "Michael", ["friend {expand(_all_)}"])
      identifier = node["uid"]
      person = %Person{person_id: "John", name: "John"}
      {:ok, node} = mutate_node_from_struct(person)

    end
  end
end
