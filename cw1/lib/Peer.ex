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
        broadcast id, peers, max_messages, timeout, 0, counter
    end
  end # next

  defp broadcast id, peers, max_messages, timeout, sent_count, counter do
    if sent_count < max_messages do
      for i <- 1..length(peers), do:
        send Enum.at(peers, i-1), { :hello, id }

      counter = Enum.map(counter, fn {s, r} -> {s+1, r} end)
    end

    receive do
      { :hello, recv_id } ->
        counter = List.update_at(counter, recv_id, fn {s, r} -> {s, r+1} end)
        broadcast id, peers, max_messages, timeout, sent_count + 1, counter
    after
      timeout ->
        output = ["#{id+1}:"]

        stats = for {sent, recv} <- counter, do: "{#{sent}:#{recv}}"

        IO.puts Enum.join(output ++ stats, " ")
    end

  end # broadcast

end # Peer
