defmodule BeamStressTest do
  @processes 100_000
  @messages_per_process 20
  @work_iterations 5_000

  def run do
    IO.puts("""
    ==========================================
             BEAM INTENSIVE STRESS TEST
    ==========================================
    Processes: #{@processes}
    Messages per process: #{@messages_per_process}
    CPU iterations: #{@work_iterations}
    ==========================================
    """)

    process_creation_test()
    message_passing_test()
    cpu_work_test()
    mixed_stress_test()

    IO.puts("\n==========================================")
    IO.puts("             TEST COMPLETE")
    IO.puts("==========================================")
  end

  # --------------------------------------------------
  # TEST 1: MASSIVE PROCESS CREATION
  # --------------------------------------------------

  defp process_creation_test do
    IO.puts("\n[1] Creating #{@processes} processes...")

    {time, pids} =
      :timer.tc(fn ->
        Enum.map(1..@processes, fn _ ->
          spawn(fn ->
            receive do
              :stop -> :ok
            end
          end)
        end)
      end)

    seconds = time / 1_000_000

    IO.puts("Time: #{Float.round(seconds, 3)} seconds")
    IO.puts("Average: #{Float.round(time / @processes, 3)} μs/process")

    Enum.each(pids, fn pid ->
      send(pid, :stop)
    end)

    IO.puts("Processes created: #{length(pids)}")
  end

  # --------------------------------------------------
  # TEST 2: MASSIVE MESSAGE PASSING
  # --------------------------------------------------

  defp message_passing_test do
    IO.puts("\n[2] Heavy message-passing test...")

    parent = self()

    {time, _} =
      :timer.tc(fn ->
        workers =
          Enum.map(1..@processes, fn _ ->
            spawn(fn ->
              receive do
                {:work, sender} ->
                  Enum.each(1..@messages_per_process, fn i ->
                    send(sender, {:result, i})
                  end)
              end
            end)
          end)

        Enum.each(workers, fn pid ->
          send(pid, {:work, parent})
        end)

        total_messages = @processes * @messages_per_process

        collect_messages(total_messages)
      end)

    seconds = time / 1_000_000
    total_messages = @processes * @messages_per_process

    IO.puts("Messages: #{total_messages}")
    IO.puts("Time: #{Float.round(seconds, 3)} seconds")
    IO.puts(
      "Messages/sec: #{Float.round(total_messages / seconds, 0)}"
    )
  end

  defp collect_messages(0), do: :ok

  defp collect_messages(remaining) do
    receive do
      {:result, _value} ->
        collect_messages(remaining - 1)
    end
  end

  # --------------------------------------------------
  # TEST 3: CPU HEAVY WORK
  # --------------------------------------------------

  defp cpu_work_test do
    IO.puts("\n[3] CPU-heavy concurrent computation...")

    parent = self()

    {time, results} =
      :timer.tc(fn ->
        Enum.each(1..@processes, fn n ->
          spawn(fn ->
            result = heavy_calculation(n)
            send(parent, {:calculation_done, result})
          end)
        end)

        collect_calculations(@processes, [])
      end)

    seconds = time / 1_000_000

    IO.puts("Time: #{Float.round(seconds, 3)} seconds")
    IO.puts("Results collected: #{length(results)}")
  end

  defp heavy_calculation(n) do
    Enum.reduce(1..@work_iterations, 0, fn i, acc ->
      acc + :erlang.phash2({n, i}, 1_000_000)
    end)
  end


  defp collect_calculations(0, results), do: results

  defp collect_calculations(remaining, results) do
    receive do
      {:calculation_done, result} ->
        collect_calculations(
          remaining - 1,
          [result | results]
        )
    end
  end

  # --------------------------------------------------
  # TEST 4: MIX EVERYTHING TOGETHER
  # --------------------------------------------------

  defp mixed_stress_test do
    IO.puts("\n[4] MIXED CONCURRENCY STRESS TEST...")

    parent = self()

    start_time = System.monotonic_time(:millisecond)

    Enum.each(1..@processes, fn n ->
      spawn(fn ->
        # CPU work
        result =
          Enum.reduce(1..@work_iterations, 0, fn i, acc ->
            acc + :erlang.phash2({n, i})
          end)

        # Message passing
        send(parent, {:worker_done, result})
      end)
    end)

    collect_mixed(@processes)

    end_time = System.monotonic_time(:millisecond)

    duration = end_time - start_time

    IO.puts("Time: #{duration} ms")
    IO.puts("Workers completed: #{@processes}")
    IO.puts(
      "Workers/sec: #{Float.round(@processes / (duration / 1000), 2)}"
    )
  end

  defp collect_mixed(0), do: :ok

  defp collect_mixed(remaining) do
    receive do
      {:worker_done, _result} ->
        collect_mixed(remaining - 1)
    end
  end
end
