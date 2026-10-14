defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new() do
    %TodoList{}
  end

  def add_entry(%TodoList{} = todolist, entry) do
    entry = Map.put(entry, :id, todolist.next_id)

    new_entries = Map.put(
      todolist.entries,
      todolist.next_id,
      entry
    )

    %TodoList{
      todolist |
      entries: new_entries,
      next_id: todolist.next_id + 1}
  end

  def update_entry(%TodoList{} = todolist, entry_id, updater_fn) do
    case Map.fetch(todolist.entries, entry_id) do
      :error ->
        todolist

      {:ok, old_entry} ->
        new_entry = updater_fn.(old_entry)
        new_entries = Map.put(todolist.entries, new_entry.id, new_entry)
        %TodoList{todolist | entries: new_entries}
    end
  end

  def entries(%TodoList{} = todolist, date) do
    todolist.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

end



defmodule TodoServer do

  def start() do
    spawn(fn -> loop(TodoList.new()) end)
  end

  def loop(current_entry) do
    new_entry = receive do

      {server_pid, {:entries, date}} ->
        entry = TodoList.entries(current_entry, date)
        send(server_pid, {:response, entry})
        current_entry

      {:add_entry, entry} -> TodoList.add_entry(current_entry, entry)
      invalid_request ->
          IO.puts("Invalid request: #{inspect(invalid_request)}")
      current_entry
    end
    loop(new_entry)
  end

    def add_entry(server_pid, entry), do: send(server_pid, {:add_entry, entry})

    def entries(server_pid, date) do
      send(server_pid, {self(), {:entries, date}})

      receive do
        {:response, entry} ->
          IO.puts(entry)
        end
    end
end
