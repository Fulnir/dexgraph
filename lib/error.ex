defmodule DexGraph.Gremlin.GremlinError do
  defexception [:status, :message]
  @type t :: %__MODULE__{status: non_neg_integer, message: String.t()}

  def exception(status, message) do
    %DexGraph.Gremlin.GremlinError{status: status, message: message}
  end
end
