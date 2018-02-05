# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule FD do

  def start do
    IO.puts ["\tFD at ", DNS.my_ip_addr()]

    receive do
      { :bind, lrb, pl, lpls, delay } ->
        #wait_for_broadcast , lpl, lrb, lpls
        Process.send_after(self(), :timeout, delay)
        next lrb, pl, MapSet.new(lpls), delay, MapSet.new(lpls), MapSet.new
    end
  end # start

  def next lrb, pl, lpls, delay, alive, detected do
    receive do
      { :pl_deliver, from, :heartbeat_request } ->
        send pl, { :pl_send, from, :heartbeat_reply }
        next lrb, pl, lpls, delay, alive, detected

      { :pl_deliver, from, :heartbeat_reply } ->
        next lrb, pl, lpls, delay, MapSet.put(alive, from), detected

      :timeout ->
        more_detected = MapSet.new(
          for p <- lpls,
            not MapSet.member?(alive, p)
            and not MapSet.member?(detected, p),
          do: p)
        for p <- more_detected, do: send lrb, { :fd_crash, p }
        for p <- alive, do: send pl, { :pl_send, p, :heartbeat_request }
        Process.send_after(self(), :timeout, delay)
        next lrb, pl, alive, delay, MapSet.new([]), MapSet.union(detected, more_detected)
    end
  end # next

end # FD
