# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule App do

  def start id do
    receive do
      {:bind, beb } ->
        wait_for_broadcast id, beb
    end
  end # start

  defp wait_for_broadcast id, beb do
    receive do
      { :beb_deliver, max_messages, timeout } ->
        counter = for _ <- 1..5, do: {0, 0}
        broadcast id, beb, max_messages, curr_time() + timeout, counter
    end
  end # next

  defp broadcast id, beb, messages, end_time, counter do
    cond do
      curr_time() >= end_time ->
        stats = for {sent, recv} <- counter, do: "{#{sent}:#{recv}}"
        IO.puts Enum.join(["#{id}:"] ++ stats, " ")

      messages > 0 ->
        send beb, { :beb_broadcast, :hello }

        counter = Enum.map(counter, fn {s, r} -> {s+1, r} end)

        receive do
          { :beb_deliver, from, :hello } ->
            counter = List.update_at(counter, from - 1, fn {s, r} -> {s, r+1} end)
            broadcast id, beb, messages - 1, end_time, counter
        after
          0 ->
            broadcast id, beb, messages - 1, end_time, counter
        end

      true ->
        receive do
          { :beb_deliver, from, :hello } ->
            counter = List.update_at(counter, from - 1, fn {s, r} -> {s, r+1} end)
            broadcast id, beb, messages - 1, end_time, counter
        after
          0 ->
            broadcast id, beb, messages, end_time, counter
        end
    end

  end # broadcast

  defp curr_time do
        :os.system_time(:millisecond)
  end

end
