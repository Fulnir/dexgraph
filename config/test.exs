use Mix.Config

# Application.put_env(:elixir, :ansi_enabled, true)
config :elixir, ansi_enabled: true

# Print only warnings and errors during test
config :logger, level: :debug

# Logger.debug "💡 struct_name #{inspect struct_name}", [my_id: 1234]
config :logger, :console,
  format: "🛡  $metadata$message\n",
  metadata: [:function, :my_id], # metadata: [:module, :function, :my_id],
  colors: [
    warn: IO.ANSI.color(172),
    info: IO.ANSI.color(229),
    error: IO.ANSI.color(196),
    debug: IO.ANSI.color(153)
  ]

# Dgraph konfigurieren

# Dgraph konfigurieren
# http://elixir-recipes.github.io/mix/configuration/
# http://sheldonkreger.com/understanding-config-in-elixir.html
# IO.inspect(Application.get_env(Seneca, Seneca.DexGraph, :server)
config :dexgraph,
  server: "http://localhost:8082" # 8082
