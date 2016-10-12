defmodule Hrafn.Event do
  @moduledoc """
  Struct for holding a Hrafn event
  """

  @type t :: %__MODULE__{
    event_id: String.t,
    environment: String.t,
    culprit: nil,
    timestamp: String.t,
    message: String.t,
    tags: Map.t,
    level: String.t,
    platform: String.t,
    server_name: String.t,
    exception: Map.t,
    extra: Map.t
  }

  defstruct event_id: nil,
            environment: nil,
            culprit: nil,
            timestamp: nil,
            message: nil,
            tags: %{},
            level: "error",
            platform: "other",
            server_name: nil,
            exception: nil,
            extra: %{}
end
