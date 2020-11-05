defmodule CircuitBreaker.Api.Switch do
  use GenStateMachine, callback_mode: :state_functions

  @name :circuit_breaker_switch
  @error_count_limit 8
  @time_to_half_open_delay 8000

  def start_link do
    GenStateMachine.start_link(__MODULE__, {:closed, %{error_count: 0}}, name: @name)
  end

  def get_positions do
    GenStateMachine.call(@name, :get_positions)
  end

  def closed({:call, from}, :get_positions, data) do
    case CircuitBreaker.Api.GithubJobs.get_positions() do
      {:ok, positions} ->
        {:keep_state, %{error_count: 0}, {:reply, from, {:ok, positions}}}
      {:error, reason} ->
        handle_error(reason, from, %{ data | error_count: data.error_count + 1 })
    end
  end

  def half_open({:call, from}, :get_positions, data) do
    case CircuitBreaker.Api.GithubJobs.get_positions() do
      {:ok, positions} ->
        {:next_state, :closed, %{count_error: 0}, {:reply, from, {:ok, positions}}}
      {:error, reason} ->
        open_circuit(from, data, reason, @time_to_half_open_delay)
    end
  end

  def open({:call, from}, :get_positions, data) do
    {:keep_state, data, {:reply, from, {:error, :circuit_open}}}
  end

  def open(:info, :to_half_open, data) do
    {:next_state, :half_open, data}
  end

  defp handle_error(reason, from, data = %{error_count: error_count}) when error_count > @error_count_limit do
      open_circuit(from, data, reason, @time_to_half_open_delay)
  end

  defp handle_error(reason, from, data) do
    {:keep_state, data, {:reply, from, {:error, reason}}}
  end

  defp open_circuit(from, data, reason, delay) do
    Process.send_after(@name, :to_half_open, delay)
    {:next_state, :open, data, {:reply, from, {:error, reason}}}
  end
end
