# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule PL do

  def start id do
    receive do
      { :bind, beb } -> wait_for_broadcast id, beb
    end
  end

  defp wait_for_broadcast id, beb do
    receive do
      { :pl_send, max_broadcasts, timeout } ->
        send beb, { :pl_deliver, max_broadcasts, timeout }
        next id, beb
    end
  end

  defp next id, beb do
    receive do
      { :pl_send, id, to_pid, message } ->
        send to_pid, { :pl_deliver, id, message }

      { :pl_deliver, from, message } ->
        send beb, { :pl_deliver, from, message }
    end

    next id, beb
  end

end
