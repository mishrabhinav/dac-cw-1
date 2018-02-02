# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule App do

  def start id do
    receive do
      {:bind, peer_pls } ->
        [{ _, pl }] = Enum.filter(peer_pls, fn { app_id, _ } -> app_id == id end)
        wait_for_broadcast id, pl, peer_pls
    end
  end # start

  defp wait_for_broadcast id, pl, peer_pls do
    receive do
      { :pl_deliver, max_messages, timeout } ->
        counter = for _ <- 1..length(peer_pls), do: {0, 0}
        broadcast id, peer_pls, pl, max_messages, curr_time() + timeout, counter
    end
  end # next

  defp broadcast id, peer_pls, pl, messages, end_time, counter do
    cond do
      curr_time() >= end_time ->
        stats = for {sent, recv} <- counter, do: "{#{sent}:#{recv}}"
        IO.puts Enum.join(["#{id}:"] ++ stats, " ")

      messages > 0 ->
        for i <- 1..length(peer_pls) do
          [{ _, to_pl }] = Enum.filter(peer_pls, fn { app_id, _ } -> app_id == i end)
          send pl, { :pl_send, to_pl, :hello }
        end

        counter = Enum.map(counter, fn {s, r} -> {s+1, r} end)

        receive do
          { :pl_deliver, recv_id, :hello } ->
            counter = List.update_at(counter, recv_id - 1, fn {s, r} -> {s, r+1} end)
            broadcast id, peer_pls, pl, messages - 1, end_time, counter
        after
          0 ->
            broadcast id, peer_pls, pl, messages - 1, end_time, counter
        end

      true ->
        receive do
          { :pl_deliver, recv_id, :hello } ->
            counter = List.update_at(counter, recv_id - 1, fn {s, r} -> {s, r+1} end)
            broadcast id, peer_pls, pl, messages, end_time, counter
        after
          0 ->
            broadcast id, peer_pls, pl, messages, end_time, counter
        end
    end

  end # broadcast

  defp curr_time do
        :os.system_time(:millisecond)
  end

end
