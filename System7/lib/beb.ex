# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule BEB do

  def start id do
    IO.puts ["\tBEB at ", DNS.my_ip_addr()]

    receive do
      { :bind, lpl, lrb, lpls } ->
        wait_for_broadcast id, lpl, lrb, lpls
    end
  end # start

  defp wait_for_broadcast id, lpl, lrb, lpls do
    receive do
      { :pl_deliver, max_broadcasts, timeout } ->
        send lrb, { :beb_deliver, max_broadcasts, timeout }
        next id, lpl, lrb, lpls
    end
  end # wait_for_broadcast

  defp next id, lpl, lrb, lpls do
    receive do
      { :beb_broadcast, lrb_m } ->
        for { _, dest } <- lpls, do:
          send lpl, { :pl_send, id, dest, lrb_m }

      { :pl_deliver, from, lrb_m } ->
        send lrb, { :beb_deliver, from, lrb_m }
    end

    next id, lpl, lrb, lpls
  end #next

end # BEB
