defmodule GremlinAddTest do
    @moduledoc """
    
    Copyright © 2018 Edwin Buehler. All rights reserved.
    """
    use ExUnit.Case
    doctest DexGraph
    import DexGraph
    import Gremlin
    # import Person
    # alias DexGraph.Person
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

    test "Add gremlin steps" do
        {:ok, graph} = Graph.new
        graph
            |> addV(Person)
            |> property("name", "Bugs Bunny")
            |> property("type", "Toon")
      {:ok, node} = query_node("name", "Bugs Bunny", ["age", "type", "vertex_type"])
      assert "Bugs Bunny" == node["name"]
      assert "Person" == node["vertex_type"]
      assert "Toon" == node["type"]
      #
      {:ok, node} = mutate_node("id", "Duffy")
      identifier = node["uids"]["identifier"]
      {:ok, node} = query_node("id", "Duffy")
      {:ok, _} = mutate_node(identifier, "id", "Duffy")
      {:ok, node} = query_node("name", "Bugs Bunny")
      assert "Bugs Bunny" == node["name"]
      {:ok, node} = query_node("id", "Duffy")
      assert identifier == node["uid"]
    end
  
  end
  