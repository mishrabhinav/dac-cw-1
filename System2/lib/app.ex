defmodule App do

  def start do
    receive do
      {:init, id, pl } -> wait_for_broadcast id, pl
    end
  end # start

  defp wait_for_broadcast id, pl do
    receive do
      { :broadcast, max_messages, timeout } ->
        counter = for _ <- 1..5, do: {0, 0}
        broadcast id, pl, max_messages, curr_time() + timeout, counter
    end
  end # next

  defp broadcast id, pl, messages, end_time, counter do
    cond do
      curr_time() >= end_time ->
        stats = for {sent, recv} <- counter, do: "{#{sent}:#{recv}}"
        IO.puts Enum.join(["#{id}:"] ++ stats, " ")

      messages > 0 ->
        for i <- 1..5, do:
          send pl, { :pl_send, i, :hello }

        counter = Enum.map(counter, fn {s, r} -> {s+1, r} end)

        receive do
          { :pl_deliver, recv_id, :hello } ->
            counter = List.update_at(counter, recv_id - 1, fn {s, r} -> {s, r+1} end)
            broadcast id, pl, messages - 1, end_time, counter
        after
          0 ->
            broadcast id, pl, messages - 1, end_time, counter
        end

      true ->
        receive do
          { :pl_deliver, recv_id, :hello } ->
            counter = List.update_at(counter, recv_id - 1, fn {s, r} -> {s, r+1} end)
            broadcast id, pl, messages, end_time, counter
        after
          0 ->
            broadcast id, pl, messages, end_time, counter
        end
    end

  end # broadcast

  defp curr_time do
        :os.system_time(:millisecond)
  end

end
