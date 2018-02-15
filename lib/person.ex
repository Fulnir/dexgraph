defmodule Person do
    @moduledoc """
    Sample struct Person.

    Copyright © 2018 Edwin Buehler. All rights reserved.
    """
    require Logger

    alias Person
    @doc """
    Die Variablen
    """
    @enforce_keys [:person_id]
    defstruct person_id: String,
        address: [],
        name: String,
        friend: [],
        alchemist: false,
        gender: Atom,
        age: Integer,
        aliases: [],
        comment: String

    @doc """
    Creates a new person
    """
    def new(id) do
        {:ok, %Person{person_id: id}}
    end
end
