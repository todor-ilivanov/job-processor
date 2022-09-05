defmodule JobProcessor.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "OK")
  end

  post "/process" do
    chained = conn.query_params["chained"] == "true"
    processed = JobProcessor.process(conn.body_params["tasks"])

    processed =
      if chained do
        processed |> Enum.map(fn task -> task.command end) |> Enum.join(" && ")
      else
        processed
      end

    send_resp(conn, 200, Jason.encode!(processed))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    message = if reason.message != nil, do: reason.message, else: "Something went wrong"
    status_code = if reason.status_code != nil, do: reason.status_code, else: conn.status
    IO.inspect(conn.status)
    send_resp(conn, status_code, message)
  end
end
