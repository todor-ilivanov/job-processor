defmodule JobProcessorTest do
  use ExUnit.Case
  doctest JobProcessor

  test "greets the world" do
    assert JobProcessor.hello() == :world
  end
end
