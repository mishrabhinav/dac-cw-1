# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule App do

  def start id do
    IO.puts ["\tApp at ", DNS.my_ip_addr()]

    receive do
      {:bind, lrb, num_peers } ->
        wait_for_broadcast id, lrb, num_peers
    end
  end # start

  defp wait_for_broadcast id, lrb, num_peers do
    receive do
      { :lrb_deliver, max_messages, timeout } ->
        counter = for _ <- 1..num_peers, do: {0, 0}
        broadcast id, lrb, max_messages, curr_time() + timeout, counter
    end
  end # wait_for_broadcast

  defp broadcast id, lrb, messages, end_time, counter do
    cond do
      curr_time() >= end_time ->
        stats = for {sent, recv} <- counter, do: "{#{sent}:#{recv}}"
        IO.puts Enum.join(["#{id}:"] ++ stats, " ")

      messages > 0 ->
        send lrb, { :lrb_broadcast, :hello }

        counter = Enum.map(counter, fn {s, r} -> {s+1, r} end)

        receive do
          { :lrb_deliver, from, :hello } ->
            counter = List.update_at(counter,
                                     from - 1,
                                     fn {s, r} -> {s, r+1} end)
            broadcast id, lrb, messages - 1, end_time, counter
        after
          0 ->
          broadcast id, lrb, messages - 1, end_time, counter
        end

      true ->
        receive do
          { :lrb_deliver, from, :hello } ->
            counter = List.update_at(counter,
                                     from - 1,
                                     fn {s, r} -> {s, r+1} end)
            broadcast id, lrb, messages - 1, end_time, counter
        after
          0 ->
            broadcast id, lrb, messages, end_time, counter
        end
    end

  end # broadcast

  defp curr_time do
        :os.system_time(:millisecond)
  end # curr_time

end # App
