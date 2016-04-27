Elixir [Sentry](https://getsentry.com) client for [Brando](http://github.com/twined/brando) applications.

## Installation

Add Hrafn as a dependency to your `mix.exs` file:

```elixir
def application do
  [applications: [:hrafn]]
end

defp deps do
  [{:hrafn, "~> 0.0.1"}]
end
```

Then run `mix deps.get` in your shell to fetch the dependencies.

### Configuration

```elixir
config :hrafn,
  dsn: "https://xxx:yyy@app.getsentry.com/12345",
  logger_level: :error,
  environment: :prod,
  ignored_exceptions: [Ecto.NoResultsError, Phoenix.Router.NoRouteError]
```

## Usage

### Logger Backend

There is a Logger backend to send logs to the Sentry,
which could be configured as follows:

```elixir
config :logger,
  backends: [Hrafn.LoggerBackend]
```

### Plug

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Hrafn.Plug, otp_app: :your_app

  # ...
end
```

## Attributions

This project is merely an extension and customization of the following projects:

 - [ravenex](https://github.com/hayesgm/ravenex)
 - [Airbrakex](https://github.com/fazibear/airbrakex)
 - [raven-elixir](https://github.com/vishnevskiy/raven-elixir)
