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

  test "/process returns multiple correctly processed jobs in order with no dependencies" do
    req_body = %{
      "tasks" => [
        %{"command" => "touch /tmp/file1", "name" => "task-1"},
        %{"command" => "cat /tmp/file1", "name" => "task-2"},
        %{"command" => "echo 'Hello World!' > /tmp/file1", "name" => "task-3"}
      ]
    }

    expected_resp = [
      %{"command" => "touch /tmp/file1", "name" => "task-1"},
      %{"command" => "cat /tmp/file1", "name" => "task-2"},
      %{"command" => "echo 'Hello World!' > /tmp/file1", "name" => "task-3"}
    ]

    assert_process_endpoint_successful(req_body, expected_resp)
  end

  test "/process returns multiple correctly processed jobs with multiple dependencies" do
    req_body = %{
      "tasks" => [
        %{"command" => "touch /tmp/file1", "name" => "task-1"},
        %{
          "command" => "cat /tmp/file1",
          "name" => "task-2",
          "requires" => ["task-3"]
        },
        %{
          "command" => "echo 'Hello World!' > /tmp/file1",
          "name" => "task-3",
          "requires" => ["task-1"]
        },
        %{
          "command" => "rm /tmp/file1",
          "name" => "task-4",
          "requires" => ["task-2", "task-3"]
        }
      ]
    }

    expected_resp = [
      %{"command" => "touch /tmp/file1", "name" => "task-1"},
      %{"command" => "echo 'Hello World!' > /tmp/file1", "name" => "task-3"},
      %{"command" => "cat /tmp/file1", "name" => "task-2"},
      %{"command" => "rm /tmp/file1", "name" => "task-4"}
    ]

    assert_process_endpoint_successful(req_body, expected_resp)
  end

  test "/process returns error on missing body" do
    conn = conn(:post, "/process")

    assert_raise Plug.Conn.WrapperError, "** (RuntimeError) No tasks provided.", fn ->
      conn = JobProcessor.Router.call(conn, @opts)
    end
  end

  test "/process returns error on malformed request" do
    conn = conn(:post, "/process", %{dogs: ["small", "medium", "large"]})

    assert_raise Plug.Conn.WrapperError, "** (RuntimeError) No tasks provided.", fn ->
      conn = JobProcessor.Router.call(conn, @opts)
    end
  end

  defp assert_process_endpoint_successful(req_body, expected_resp) do
    conn = conn(:post, "/process", req_body)
    conn = JobProcessor.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == Jason.encode!(expected_resp)
  end
end
