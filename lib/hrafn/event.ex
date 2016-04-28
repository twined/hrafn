defmodule Hrafn.Event do
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
