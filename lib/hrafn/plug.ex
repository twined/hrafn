defmodule Hrafn.Plug do

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    quote location: :keep do
      @otp_app unquote(otp_app)
      @before_compile Hrafn.Plug
    end
  end

  defmacro __before_compile__(env) do
    otp_app            = Module.get_attribute(env.module, :otp_app)
    ignored_exceptions = Application.get_env(:hrafn, :ignored_exceptions, [])
    public_dsn         = Application.get_env(:hrafn, :public_dsn, nil)

    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            real_exception =
              if Map.get(exception, :__struct__) == Plug.Conn.WrapperError do
                if is_map(exception.reason) do
                  Map.get(exception.reason, :__struct__, nil)
                else
                  exception.reason
                end
              else
                Map.get(exception, :__struct__, nil)
              end

            options =
              %{}
              |> Map.put(:otp_app, unquote(otp_app))
              |> Map.put(:conn, conn)
              |> Map.put(:event_id, UUID.uuid4(:hex))

            exception =
              if real_exception in unquote(ignored_exceptions) do
                exception
              else
                exception
                |> Hrafn.ExceptionParser.parse
                |> Hrafn.Notifier.notify(options)

                private =
                  exception.conn.private
                  |> Map.put(:hrafn_event_id, options.event_id)
                  |> Map.put(:hrafn_public_dsn, unquote(public_dsn))
                  
                put_in(exception.conn.private, private)
              end

            reraise exception, System.stacktrace
        end
      end
    end
  end
end
