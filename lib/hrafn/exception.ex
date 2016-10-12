defmodule Hrafn.Exception do
  @moduledoc """
  Custom exception struct
  """
  defstruct type: nil,
            message: nil,
            backtrace: nil
end
