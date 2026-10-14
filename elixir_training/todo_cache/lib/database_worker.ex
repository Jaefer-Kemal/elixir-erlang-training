defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({database_folder, worker_id}) do
    GenServer.start_link(
      __MODULE__,
      database_folder,
      name: via_tuple(worker_id)
    )
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  @impl GenServer
  def init(database_folder) do
    IO.puts("Starting database worker.")
    File.mkdir_p!(database_folder)
    {:ok, database_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, database_folder) do
    key
    |> file_name(database_folder)
    |> File.write(:erlang.term_to_binary(data))

    {:noreply, database_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, database_folder) do
    data =
      case File.read(file_name(key, database_folder)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, database_folder}
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  defp file_name(key, database_folder) do
    Path.join(database_folder, to_string(key))
  end
end
