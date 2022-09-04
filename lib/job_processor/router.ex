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
    IO.inspect(conn.body_params)
    send_resp(conn, 200, Jason.encode!(conn.body_params))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
