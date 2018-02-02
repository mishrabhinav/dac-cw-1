# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule LPL do

  def start id, drop_rate do
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
      { :pl_send, id, to_pid, message } ->
        if :rand.uniform(100) <= drop_rate, do:
          send to_pid, { :pl_deliver, id, message }

      { :pl_deliver, from, message } ->
        send beb, { :pl_deliver, from, message }
    end

    next id, beb, drop_rate
  end # next

end # PL
