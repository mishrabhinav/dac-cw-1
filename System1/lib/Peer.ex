# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule Peer do

  def start do
    receive do
      {:bind, id, peers } -> next(id, peers)
    end
  end # start

  defp next id, peers do
    receive do
      { :broadcast, max_messages, timeout } ->
        counter = for _ <- peers, do: {0, 0}
        broadcast id, peers, max_messages, curr_time() + timeout, counter
    end
  end # next

  defp broadcast id, peers, messages, end_time, counter do
    cond do
      curr_time() >= end_time ->
        stats = for {sent, recv} <- counter, do: "{#{sent}:#{recv}}"
        IO.puts Enum.join(["#{id}:"] ++ stats, " ")

      messages > 0 ->
        for i <- 1..length(peers), do:
          send Enum.at(peers, i-1), { :hello, id }

        counter = Enum.map(counter, fn {s, r} -> {s+1, r} end)

        receive do
          { :hello, recv_id } ->
            counter = List.update_at(counter, recv_id, fn {s, r} -> {s, r+1} end)
            broadcast id, peers, messages - 1, end_time, counter
        after
          0 ->
            broadcast id, peers, messages - 1, end_time, counter
        end

      true ->
        receive do
          { :hello, recv_id } ->
            counter = List.update_at(counter, recv_id, fn {s, r} -> {s, r+1} end)
            broadcast id, peers, messages, end_time, counter
        after
          0 ->
            broadcast id, peers, messages , end_time, counter
        end
    end

  end # broadcast

  defp curr_time do
        :os.system_time(:millisecond)
  end

end # Peer
