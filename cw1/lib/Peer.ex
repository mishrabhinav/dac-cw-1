# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do
  def start() do
    receive do
      { id, peers } -> next(id, peers)
    end
  end

  defp next(id, peers) do
    receive do
      { :broadcast, max_messages, timeout } -> broadcast id, peers, max_messages, timeout, 0, %{}, %{}
    end
  end

  defp broadcast(id, peers, max_messages, timeout, sent_count, sent_map, receive_map) do
    new_sent_count = sent_count
    for i <- 1..length(peers) do
      Map.update(sent_map, i, 1, &(&1 + 1))
      new_sent_count = new_sent_count + 1
      send Enum.at(peers, i - 1), { :hello, id }
    end

    receive do
      { :hello, id } ->
        Map.update(receive_map, id, 1, &(&1 + 1))
        broadcast(id, peers, max_messages, timeout, new_sent_count, sent_map, receive_map)
    after timeout ->
      IO.puts [id, " timed out"]
    end
  end
end
