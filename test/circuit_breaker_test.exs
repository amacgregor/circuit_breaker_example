defmodule CircuitBreakerTest do
  use ExUnit.Case
  doctest CircuitBreaker

  test "greets the world" do
    assert CircuitBreaker.hello() == :world
  end
end
