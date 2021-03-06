defmodule Database.Lookups do
  @moduledoc """
  Manifest information about the services provided are stored in
  yaml files, and this module will find the relevant information
  and store it in ETS for fast retrieval.
  """
  alias Poison, as: JSON

  def load do
    load_distincts
  end

  def load_distincts() do
     :ets.new(:distincts, [:named_table, read_concurrency: true])

     root = Path.join( [System.get_env("MANIFESTS") || "/tmp/__/", "distincts"])
     path = Path.join( [root, "*.json"])

     case File.exists?(root) do
        true ->
          path
           |>  Path.wildcard
           |> Enum.each(&load_distinct/1)
        _ ->
            nil
      end
  end

  defp load_distinct(distincts_file) do
    %{"theme"=> theme} = Regex.named_captures(
        ~r/.*\/(?<theme>\w+)\.json/, distincts_file)

    blob = distincts_file
    |> File.read!
    |> JSON.decode!

    :ets.insert(:distincts, {theme, blob})
  end

  defp process_service(service) do
    service_name = service["name"]
    service["searchables"]
    |> Enum.map(fn s->
      sname = s["name"]
      {"#{service_name}/#{sname}", %{"query"=> s["query"],
                                     "name"=>s["name"],
                                     "fields"=>s["fields"],
                                     "large_dataset"=>Map.get(s,"large_dataset", false)} }
    end)
  end

  @doc """
  Find service by providing the key.
  Choices for type are currently :services or :themes or :distincts
  """
  def find(type, key) do
    case :ets.lookup(type, key) do
      [{^key, bucket}] -> bucket
      [] -> nil
    end
  end

  def find_all(type) do
    :ets.tab2list(type)
    |> Enum.into %{}
  end

end
