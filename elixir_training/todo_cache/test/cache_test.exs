defmodule Todo.CacheTest do
  use ExUnit.Case

  setup do
    start_supervised!(Todo.System)
    cache = Process.whereis(Todo.Cache)

    {:ok, cache: cache}
  end

  test "server_process", %{cache: cache} do
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert ^bob_pid = Todo.Cache.server_process(cache, "bob")
  end

  test "to-do operations", %{cache: cache} do
    list_name = "alice_#{System.unique_integer([:positive])}"
    alice = Todo.Cache.server_process(cache, list_name)
    Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})

    entries = Todo.Server.entries(alice, ~D[2023-12-19])

    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
  end

  test "database and cache are sibling processes", %{cache: cache} do
    database = Process.whereis(Todo.Database)

    Process.exit(database, :kill)

    assert Process.alive?(cache)
    assert wait_for_process(Todo.Database)

    Process.exit(cache, :kill)

    assert wait_for_process(Todo.Database)
  end

  defp wait_for_process(name, attempts \\ 10)

  defp wait_for_process(name, 0), do: is_pid(Process.whereis(name))

  defp wait_for_process(name, attempts) do
    case Process.whereis(name) do
      pid when is_pid(pid) ->
        if Process.alive?(pid) do
          true
        else
          Process.sleep(10)
          wait_for_process(name, attempts - 1)
        end
      nil ->
        Process.sleep(10)
        wait_for_process(name, attempts - 1)
      _pid ->
        Process.sleep(10)
        wait_for_process(name, attempts - 1)
    end
  end

end
