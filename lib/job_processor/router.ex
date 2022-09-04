defmodule JobProcessor.Router do
  use Plug.Router

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
    try do
      processed = JobProcessor.process(conn.body_params["tasks"])
      send_resp(conn, 200, Jason.encode!(processed))
    rescue
      e in _ ->
        IO.inspect(e)
        send_resp(conn, 400, "Bad request")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
