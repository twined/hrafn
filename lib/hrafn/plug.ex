defmodule Hrafn.Plug do

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    quote location: :keep do
      @otp_app unquote(otp_app)
      @before_compile Hrafn.Plug
    end
  end

  defmacro __before_compile__(env) do
    otp_app = Module.get_attribute(env.module, :otp_app)
    ignored_exceptions = Application.get_env(:hrafn, :ignored_exceptions, [])

    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            real_exception =
              if exception.__struct__ == Plug.Conn.WrapperError do
                Map.get(exception.reason, :__struct__, nil)
              else
                Map.get(exception, :__struct__, nil)
              end

            unless real_exception in unquote(ignored_exceptions) do
              exception
              |> Hrafn.ExceptionParser.parse
              |> Hrafn.Notifier.notify(conn, unquote(otp_app))
            end

            reraise exception, System.stacktrace
        end
      end
    end
  end
end
