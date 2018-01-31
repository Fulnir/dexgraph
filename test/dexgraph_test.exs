defmodule DexGraphTest do
    @moduledoc """
    #
    # Copyright © 2018 Edwin Buehler. All rights reserved.
    #
    """
    use ExUnit.Case
    doctest DexGraph

    import DexGraph

    require Logger

    @testing_schema "id: string @index(exact).
      name: string @index(exact, term) @count .
      age: int @index(int) .
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
  
    setup_all do
        IO.puts "DexGraph setup all: #{Application.get_env(:dexgraph, :server)}"
        # Komplette Datenbank löschen
        alter("{\"drop_all\": true}")
        # Schema
        write_schema(@testing_schema)
        # Daten
        _ = write_testing_data(@testing_data)
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
        {:ok, _} = mutate_node("name", "Edwin Bühler")
        {:ok, node} = query_node("name", "Edwin Bühler")
        assert "Edwin Bühler" == node["name"]
        {:ok, node} = mutate_node("id", "EdwinBühler")
        identifier = node["uids"]["identifier"]    
        {:ok, _} = mutate_node(identifier, "id", "EdwinBühler")
        {:ok, node} = query_node("name", "Edwin Bühler")
        assert "Edwin Bühler" == node["name"]
        {:ok, node} = query_node("id", "EdwinBühler")
        assert identifier == node["uid"]
    end
  
    test "Add node as struct" do
        {:ok, node} = mutate_node(%{node_type: :person, name: "Edwin", address: "Wassenberg"})
        assert "Success" == node["code"]
    end
  
  end
  