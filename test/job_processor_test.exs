defmodule JobProcessorTest.Router do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts JobProcessor.Router.init([])

  test "return ok" do
    conn = conn(:get, "/")
    conn = JobProcessor.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "/process returns back the request" do
    req_body = %{tasks: [%{command: "touch /tmp/file1", name: "task-1"}]}
    conn = conn(:post, "/process", req_body)
    conn = JobProcessor.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == Jason.encode!(req_body)
  end
end
