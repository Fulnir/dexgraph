defmodule Person do
    @moduledoc """
    Sample

    Copyright © 2018 Edwin Buehler. All rights reserved.
    """
    require Logger

    alias Person
    @doc """
    Die Variablen
    """
    @enforce_keys [:thing_id, :locked]
    defstruct thing_id: String, # ID sollte auch der englische Name sein
        names: [],  # Der Name in verschiedenen Sprachen
        locked: Boolean,    # Gesperrt, nicht mehr veränderbar
        #namespace: Person,   # Zur Trennung der Modelle
        user_id: Integer,      # Nutzer-ID
        type_of: [],        # Ein Exemplar(Typ) von
        inherit_from: [],   # Erbt von Elter
        property_types: [],     # Eigenschaftstypen
        property_values: [],# Die Eigenschaftswerte
        comment: String

        
    @doc """
    
    """
    def new(id) do
        thing = %Person{thing_id: id, locked: false}
        IO.puts "Thing: #{thing.thing_id}"
        {:ok, thing}
    end

    @doc """
    
    """
    def new(id, parent) do
        thing = %Person{thing_id: id, locked: false,
        inherit_from: [parent]}
        # Logger.info "Thing #{inspect thing}"

        {:ok, thing}
    end

    @doc """
    Ein Property hinzufügen
    """
    def add_property(a_thing, a_property) do
        updated_thing = %Person{a_thing | property_types: [a_property | a_thing.property_types]}
        {:ok, updated_thing}
    end

    @doc """
    Ein Propertyvalue hinzufügen
    """
    def add_property_value(a_thing, a_property, a_property_value) do
        updated_thing = %Person{a_thing | property_values: [a_property_value | a_thing.property_values]}
        {:ok, updated_thing}
    end

 #  @doc """
   
#    """
#    def mutate_thing(a_thing) do
#     thing_map = Map.from_struct(a_thing)
#     IO.puts "💬 " <> "Add thing as struct #{inspect thing_map}"
#     #mutate_node(thing_map)
#     mutate_node(%{dex_node_type: :thing,
#         thing_id: "thing", name: "Thing", locked: true})
#    end
end
