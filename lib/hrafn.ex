defmodule Hrafn do
  def notify(exception, options \\ []) do
    exception
    |> Hrafn.ExceptionParser.parse 
    |> Hrafn.Notifier.notify(options)
  end
end
