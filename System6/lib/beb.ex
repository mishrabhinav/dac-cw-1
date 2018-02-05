# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule BEB do

  def start id do
    IO.puts ["\tBEB at ", DNS.my_ip_addr()]

    receive do
      { :bind, lpl, erb, lpls } ->
        wait_for_broadcast id, lpl, erb, lpls
    end
  end # start

  defp wait_for_broadcast id, lpl, erb, lpls do
    receive do
      { :pl_deliver, max_broadcasts, timeout } ->
        send erb, { :beb_deliver, max_broadcasts, timeout }
        next id, lpl, erb, lpls
    end
  end # wait_for_broadcast

  defp next id, lpl, erb, lpls do
    receive do
      { :beb_broadcast, erb_m } ->
        for { _, dest } <- lpls, do:
          send lpl, { :pl_send, id, dest, erb_m }

      { :pl_deliver, from, erb_m } ->
        send erb, { :beb_deliver, from, erb_m }
    end

    next id, lpl, erb, lpls
  end #next

end # BEB
