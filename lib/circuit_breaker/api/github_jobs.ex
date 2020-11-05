defmodule CircuitBreaker.Api.GithubJobs do

  @spec get_positions :: none
  def get_positions do
    case HTTPoison.get(url()) do
      {:ok, response} -> {:ok, parse_fields(response.body)}
      {:error, %HTTPoison.Error{id: _, reason: reason}} -> {:error, reason}
    end
  end

  defp url do
    'https://jobs.github.com/positions.json?description=php'
  end

  defp parse_fields(raw_body) do
    json_response = raw_body
    |> Poison.decode!()
    |> Enum.map(fn(entity) -> entity["title"] end)
  end
end
