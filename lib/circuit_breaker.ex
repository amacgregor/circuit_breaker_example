defmodule CircuitBreaker do
  @moduledoc """
  Documentation for `CircuitBreaker`.
  """
  def main do
    ## start the behavior
    CircuitBreaker.Api.Switch.start_link

    ## make succesive queries
    Enum.each(0..5000, fn x ->
      IO.puts("Run #{x}")
      CircuitBreaker.Api.Switch.get_positions
      |> IO.inspect
      # Process.sleep(800)
    end)
  end
end
