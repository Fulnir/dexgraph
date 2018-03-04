defmodule Person do
    @moduledoc """
    """
  
    alias Person
  
    @doc """
    A sample struct
    """
    defstruct person_id: String,
              name: String,
              friend: [],
              knows: Person,
              alchemist: Boolean,
              gender: Atom,
              age: Integer,
              aliases: [],
              comment: String
  
    @doc """
    Creates a new Person
    """
    def new(id) do
      {:ok, %Person{person_id: id}}
    end
  end
