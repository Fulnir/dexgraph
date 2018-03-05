defmodule DexGraph.Gremlin.Person do
  @moduledoc false

  alias DexGraph.Gremlin.Person

  @doc """
  A sample struct
  """
  defstruct person_id: String,
            name: String,
            alchemist: Boolean,
            gender: String,
            age: Integer,
            friend: [],
            knows: Person,
            comment: String

  @doc """
  Creates a new Person
  """
  def new(id) do
    {:ok, %Person{person_id: id}}
  end
end
