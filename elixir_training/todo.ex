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

defmodule Fraction do
  defstruct a: nil, b: nil

  def new(a, b) do
    %Fraction{a: a, b: b}
  end

  def value(%Fraction{a: a, b: b}) do
    a / b
  end

  def add(%Fraction{a: a1, b: b1}, %Fraction{a: a2, b: b2}) do
    new(
      a1 * b2 + a2 * b1,
      b2*b1)
  end
end
