defmodule Hrafn do
  def notify(exception, options \\ []) do
    Hrafn.ExceptionParser.parse(exception) |> Hrafn.Notifier.notify(options)
  end
end
