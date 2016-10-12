defmodule Hrafn.ExceptionParser do
  @moduledoc """
  Logic for parsing exception into Hrafn.Exception struct
  """
  def parse(exception) do
    %Hrafn.Exception{
      type: exception.__struct__,
      message: Exception.message(exception),
      backtrace: stacktrace(System.stacktrace)
    }
  end

  defp stacktrace(stacktrace) do
    Enum.map stacktrace, fn
      ({module, function, args, []}) ->
        %Hrafn.Stacktrace{
          filename: "unknown",
          lineno: 0,
          function: "#{module}.#{function}#{args(args)}"
        }
      ({module, function, args, [file: file, line: line_number]}) ->
        %Hrafn.Stacktrace{
          filename: "(#{module}) #{List.to_string(file)}",
          lineno: line_number,
          function: "#{function}#{args(args)}"
        }
    end
  end

  defp args(args) when is_integer(args) do
    "/#{args}"
  end
  defp args(args) when is_list(args) do
    args =
      args
      |> Enum.map(&(inspect(&1)))
      |> Enum.join(", ")

    "(#{args})"
  end
end
