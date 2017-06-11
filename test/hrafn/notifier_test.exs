defmodule Hrafn.NotifierTest do
  use ExUnit.Case
  use Plug.Test
  alias Hrafn.ExceptionParser
  alias Hrafn.LoggerParser
  alias Hrafn.Notifier

  @session Plug.Session.init(
    store: :cookie,
    key: "_app",
    encryption_salt: "yadayada",
    signing_salt: "yadayada"
  )

  @opts %{
    otp_app: :hrafn,
    event_id: "asdf"
  }

  setup do
    conn =
      conn(:get, "/")
      |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
      |> Plug.Session.call(@session)
    %{conn: conn}
  end

  test "should correctly serialize exception", %{conn: conn} do
    exception = try do
      IO.inspect("test",[],"")
    rescue
      e -> e
    end

    error = ExceptionParser.parse(exception)

    notification = Notifier.build_notification(error, Map.put(@opts, :conn, conn))

    assert notification.event_id != nil
    assert notification.device == %{}
    assert notification.environment == nil
    assert List.first(notification.exception)[:type] == FunctionClauseError
    assert List.first(notification.exception)[:value] == "no function clause matching in IO.inspect/3"
    assert List.first(notification.exception)[:stacktrace][:frames] == [
      %Hrafn.Stacktrace{filename: "(Elixir.IO) lib/io.ex", function: "inspect(\"test\", [], \"\")", lineno: 290}, %Hrafn.Stacktrace{filename: "(Elixir.Hrafn.NotifierTest) test/hrafn/notifier_test.exs", function: "test should correctly serialize exception/1", lineno: 30}, %Hrafn.Stacktrace{filename: "(Elixir.ExUnit.Runner) lib/ex_unit/runner.ex", function: "exec_test/1", lineno: 302}, %Hrafn.Stacktrace{filename: "(timer) timer.erl", function: "tc/1", lineno: 166}, %Hrafn.Stacktrace{filename: "(Elixir.ExUnit.Runner) lib/ex_unit/runner.ex", function: "-spawn_test/3-fun-1-/3", lineno: 250}]
    assert notification.extra == %{request_id: [], session: %{}}
    assert notification.level == "error"
    assert notification.logger == "Hrafn"
    assert notification.message == "no function clause matching in IO.inspect/3"
    assert notification.platform == "other"

    assert notification.server_name != nil
    assert notification.tags == %{}
    assert notification.timestamp != nil
  end

  test "should correctly serialize log", %{conn: conn} do
    exception = """
      an exception was raised:
        ** (Ecto.NoResultsError) expected at least one result but got none in query:

      from g in Test.Game,
        where: g.id == ^"d8fe9f04-8fda-4d8f-9473-67ba94dc9458"

              (ecto) lib/ecto/repo/queryable.ex:57: Ecto.Repo.Queryable.one!/4
              (test) web/channels/game_channel.ex:15: Test.GameChannel.join/3
              (phoenix) lib/phoenix/channel/server.ex:154: Phoenix.Channel.Server.init/1
              (stdlib) gen_server.erl:328: :gen_server.init_it/6
              (stdlib) proc_lib.erl:239: :proc_lib.init_p_do_apply/3
      """

    error = LoggerParser.parse(exception)

    notification = Notifier.build_notification(error, Map.put(@opts, :conn, conn))

    assert notification.event_id != nil
    assert notification.device == %{}
    assert notification.environment == nil
    assert List.first(notification.exception)[:type] == "Ecto.NoResultsError"
    assert List.first(notification.exception)[:value] == " expected at least one result but got none in query:\n\nfrom g in Test.Game,\n  where: g.id == ^\"d8fe9f04-8fda-4d8f-9473-67ba94dc9458\"\n\n"
    assert List.first(notification.exception)[:stacktrace][:frames] == [
      %{"filename" => "(ecto) lib/ecto/repo/queryable.ex", "function" => " Ecto.Repo.Queryable.one!/4", "lineno" => 57},
      %{"filename" => "(test) web/channels/game_channel.ex", "function" => " Test.GameChannel.join/3", "lineno" => 15},
      %{"filename" => "(phoenix) lib/phoenix/channel/server.ex", "function" => " Phoenix.Channel.Server.init/1", "lineno" => 154},
      %{"filename" => "(stdlib) gen_server.erl", "function" => " :gen_server.init_it/6", "lineno" => 328},
      %{"filename" => "(stdlib) proc_lib.erl", "function" => " :proc_lib.init_p_do_apply/3", "lineno" => 239}]
    assert notification.extra == %{request_id: [], session: %{}}
    assert notification.level == "error"
    assert notification.logger == "Hrafn"
    assert notification.message == " expected at least one result but got none in query:\n\nfrom g in Test.Game,\n  where: g.id == ^\"d8fe9f04-8fda-4d8f-9473-67ba94dc9458\"\n\n"
    assert notification.platform == "other"

    assert notification.server_name != nil
    assert notification.tags == %{}
    assert notification.timestamp != nil
  end
end
