# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule BEB do

  def start id do
    receive do
      { :bind, lpl, app, lpls } ->
        wait_for_broadcast id, lpl, app, lpls
    end
  end # start

  defp wait_for_broadcast id, lpl, app, lpls do
    receive do
      { :pl_deliver, max_broadcasts, timeout } ->
        send app, { :beb_deliver, max_broadcasts, timeout }
        next id, lpl, app, lpls
    end
  end # wait_for_broadcast

  defp next id, lpl, app, lpls do
    receive do
      { :beb_broadcast, message } ->
        for { _, dest } <- lpls, do:
          send lpl, { :pl_send, id, dest, message }

      { :pl_deliver, from, message } ->
        send app, { :beb_deliver, from, message }
    end

    next id, lpl, app, lpls
  end #next

end # BEB
