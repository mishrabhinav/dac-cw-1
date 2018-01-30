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
    if sent_count == 0 do
      for i <- 1..length(peers) do
        Map.update(sent_map, i, 1, &(&1 + 1))
        send Enum.at(peers, i - 1), { :hello, id }
      end
      broadcast(id, peers, max_messages, timeout, sent_count + length(peers), sent_map, receive_map)
    else
      if sent_count < max_messages do
        receive do
          { :hello, receive_id } ->
            Map.update(receive_map, receive_id, 1, &(&1 + 1))
            for i <- 1..length(peers) do
              Map.update(sent_map, i, 1, &(&1 + 1))
              send Enum.at(peers, i - 1), { :hello, id }
            end
            broadcast(id, peers, max_messages, timeout, sent_count + length(peers), sent_map, receive_map)
        after timeout ->
          IO.puts [id, " timed out"]
        end
      else
        output = "#{id}: "
        for i <- 1..length(peers) do
          output = output <> "{#{sent_map[id]}:#{receive_map[Enum.at(peers, i - 1)]}} "
        end
        IO.puts output
      end
    end
  end
end
