# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule LRB do

  def start id do
    IO.puts ["\tLRB at ", DNS.my_ip_addr()]

    receive do
      { :bind, beb, app, processes } ->
        wait_for_broadcast id, beb, app, MapSet.new(processes)
    end
  end # start

  defp wait_for_broadcast id, beb, app, processes do
    receive do
      { :beb_deliver, max_broadcasts, timeout } ->
        send app, { :lrb_deliver, max_broadcasts, timeout }
        process_msgs = Map.new(processes, fn p -> {p, MapSet.new} end)
        next id, beb, app, processes, process_msgs
    end
  end # wait_for_broadcast

  defp next id, beb, app, correct, process_msgs do
    receive do
      { :lrb_broadcast, message } ->
        send beb, { :beb_broadcast, { :lrb_data, id, message } }
        next id, beb, app, correct, process_msgs

      { :fd_crash, { crashed_id, _} } ->
        for m <- process_msgs[crashed_id], do:
          send beb, { :beb_broadcast, { :lrb_data, crashed_id, m } }
        next id, beb, app, MapSet.delete(correct, crashed_id), process_msgs

      { :beb_deliver, _, { :rb_data, sender, m } = lrb_m } ->
        if MapSet.member?(process_msgs[sender], m) do
          next id, beb, app, correct, process_msgs
        else
          send app, { :lrb_deliver, sender, m }
          sender_msgs = MapSet.put process_msgs[sender], m
          process_msgs = Map.put process_msgs, sender, sender_msgs
          unless Enum.member? correct, sender do
            send beb, { :beb_broadcast, lrb_m }
          end
          next id, beb, app, correct, process_msgs
        end
    end
  end # next

end
