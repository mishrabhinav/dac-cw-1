# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule LPL do

  def start id, drop_rate do
    IO.puts ["\tLPL at ", DNS.my_ip_addr()]

    receive do
      { :bind, beb } -> wait_for_broadcast id, beb, drop_rate
    end
  end # start

  defp wait_for_broadcast id, beb, drop_rate do
    receive do
      { :pl_send, max_broadcasts, timeout } ->
        send beb, { :pl_deliver, max_broadcasts, timeout }
        next id, beb, drop_rate
    end
  end # wait_for_broadcast

  defp next id, beb, drop_rate do
    receive do
      { :pl_send, id, to_pid, lrb_m } ->
        if :rand.uniform(100) <= drop_rate, do:
          send to_pid, { :pl_deliver, id, lrb_m }

      { :pl_deliver, from, lrb_m } ->
        send beb, { :pl_deliver, from, lrb_m }
    end

    next id, beb, drop_rate
  end # next

end # PL
