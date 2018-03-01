defmodule Graph do
    @moduledoc """
    The graph for gremlin

    Copyright © 2018 Edwin Buehler. All rights reserved.
    """
    require Logger

    #alias Graph

    @doc """
    The graph properties.
    Reserved for cache and other
    """    
    defstruct vertex_cache: nil

    @doc """
    Creates a new graph
    """
    def new do
        {:ok, %Graph{}}
    end
end
