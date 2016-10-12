defmodule Hrafn do
  @moduledoc """
  Hrafn is a sentry client for Twined applications. It intercepts exceptions/stacktraces
  and ships them to a central sentry server.

  Configuration
  =============

  ```elixir
  config :hrafn,
    dsn: "https://xxx:yyy@app.getsentry.com/12345",
    public_dsn: "https://xxx@app.getsentry.com/12345",
    logger_level: :error,
    environment: :prod,
    ignored_exceptions: [Ecto.NoResultsError, Phoenix.Router.NoRouteError]
  ```
  
  """
  def notify(exception, options \\ []) do
    exception
    |> Hrafn.ExceptionParser.parse
    |> Hrafn.Notifier.notify(options)
  end
end
