defmodule Hrafn.Notifier do
  use HTTPoison.Base

  @sentry_version 7
  @sentry_client "hrafn"
  @logger "Hrafn"

  def notify(error, conn, otp_app) do
    case Application.get_env(:hrafn, :dsn) do
      dsn when is_bitstring(dsn) ->
        build_notification(error, conn, otp_app)
        |> send_notification(dsn |> parse_dsn)
      _ -> :error
    end
  end

  def build_notification(error, conn, otp_app) do
    conn = Plug.Conn.fetch_session(conn)
    session = Map.get(conn.private, :plug_session)
    current_user = Map.get(session, "current_user", %{})
    remote_ip =
      conn
      |> Map.get(:remote_ip, {0, 0, 0, 0})
      |> Tuple.to_list
      |> Enum.join(".")

    %{
      event_id: UUID.uuid4(:hex),
      message: error[:message],
      tags: Application.get_env(:hrafn, :tags, %{}),
      server_name: :net_adm.localhost |> to_string,
      timestamp: iso8601_timestamp,
      environment: Application.get_env(:hrafn, :environment, nil),
      platform: "other",
      level: Application.get_env(:hrafn, :logger_level, "error"),
      extra: %{},
    }
    |> add_logger
    |> add_device
    |> add_error(error)
    |> add_release(otp_app)
    |> add_user(current_user, remote_ip)
    |> add_http(conn)
    |> add_extra(:session, session)
  end

  def send_notification(payload, {endpoint, public_key, private_key}) do
    headers = [
      {"User-Agent", @sentry_client},
      {"X-Sentry-Auth", authorization_header(public_key, private_key)},
    ]

    encoded_payload = Poison.encode!(payload)

    post(endpoint, encoded_payload, headers)
  end

  defp add_logger(payload) do
    Map.put(payload, :logger, @logger)
  end

  defp add_http(payload, conn) do
    http = %{
      url: "#{to_string(conn.scheme)}://#{conn.host}#{conn.request_path}",
      method: conn.method,
      query_string: conn.query_string,
      headers: Enum.into(conn.req_headers, %{}),
    }

    Map.put(payload, :request, http)
  end

  defp add_release(payload, otp_app) do
    version =
      otp_app
      |> :application.get_key(:vsn)
      |> elem(1)
      |> to_string

    Map.put(payload, :release, version)
  end

  defp add_user(payload, current_user, _) when current_user == %{} do
    payload
  end

  defp add_user(payload, current_user, remote_ip) do
    user = %{
      id: current_user.id,
      username: current_user.username,
      email: current_user.email,
      ip_address: remote_ip
    }

    Map.put(payload, :user, user)
  end

  defp add_device(payload) do
    Map.put(payload, :device, %{})
  end

  defp add_error(payload, error) do
    exception = %{
      type: error[:type],
      value: error[:message]
    } |> add_stacktrace(error[:backtrace])

    Map.put(payload, :exception, [exception])
  end

  defp add_stacktrace(exception, nil), do: exception
  defp add_stacktrace(exception, stacktrace) do
    Map.put(exception, :stacktrace, %{
      frames: stacktrace
    })
  end

  defp add_extra(payload, _key, nil), do: payload
  defp add_extra(payload, key, value) do
    extra = Map.get(payload, :extra)
    Map.put(payload, :extra, Map.put(extra, key, value))
  end

  @doc """
  Parses a Sentry DSN which is simply a URI
  """
  defp parse_dsn(dsn) do
    %URI{userinfo: userinfo, host: host, path: path, scheme: protocol} = URI.parse(dsn)
    [public_key, secret_key] = userinfo |> String.split(":", parts: 2)
    {project_id, _} = path |> String.slice(1..-1) |> Integer.parse
    endpoint = "#{protocol}://#{host}/api/#{project_id}/store/"
    {endpoint, public_key, secret_key}
  end

  @doc """
  Generates a Sentry API authorization header.
  """
  def authorization_header(public_key, secret_key, timestamp \\ nil) do
    unless timestamp do
      timestamp = unix_timestamp
    end
    "Sentry sentry_version=#{@sentry_version}, sentry_client=#{@sentry_client}, " <>
    "sentry_timestamp=#{timestamp}, sentry_key=#{public_key}, sentry_secret=#{secret_key}"
  end

  @doc """
  Get unix epoch timestamp
  """
  defp unix_timestamp do
    {mega, sec, _micro} = :os.timestamp()
    mega * (1000000 + sec)
  end

  @doc """
  Get current timestamp in iso8601
  """
  defp iso8601_timestamp do
    [year, month, day, hour, minute, second] =
      :calendar.universal_time
      |> Tuple.to_list
      |> Enum.map(&Tuple.to_list(&1))
      |> List.flatten
      |> Enum.map(&to_string(&1))
      |> Enum.map(&String.rjust(&1, 2, ?0))
    "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}"
  end
end
