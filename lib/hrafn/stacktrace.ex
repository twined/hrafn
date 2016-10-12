defmodule Hrafn.Stacktrace do
  @moduledoc """
  Struct for stacktrace
  """
  defstruct filename: nil,
            lineno: 0,
            function: nil
end
