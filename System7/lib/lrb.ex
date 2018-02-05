# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule LRB do

  def start id do
    IO.puts ["\tLRB at ", DNS.my_ip_addr()]

    receive do
      { :bind, beb, app } ->
        wait_for_broadcast id, beb, app
    end
  end # start

  defp wait_for_broadcast id, beb, app do
    receive do
      { :beb_deliver, max_broadcasts, timeout } ->
        send app, { :lrb_deliver, max_broadcasts, timeout }
        next id, beb, app, MapSet.new, 0
    end
  end # wait_for_broadcast

  defp next id, beb, app, delivered, seq do
    receive do
      { :lrb_broadcast, message } ->
        send beb, { :beb_broadcast, { :lrb_data, id, message, seq } }
        next id, beb, app, delivered, seq+1
      { :beb_deliver, _, { :lrb_data, sender, message, g_seq } = lrb_m } ->
        if MapSet.member? delivered, { sender, message, g_seq } do
          next id, beb, app, delivered, seq
        else
          send app, { :lrb_deliver, sender, message }
          send beb, { :beb_broadcast, lrb_m }
          next(id,
               beb,
               app,
               MapSet.put(delivered, { sender, message, g_seq }),
               seq)
        end
    end
  end # next

end
