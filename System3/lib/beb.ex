# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule BEB do

  def start id do
    receive do
      { :bind, pl, app, pls } ->
        wait_for_broadcast id, pl, app, pls
    end
  end

  defp wait_for_broadcast id, pl, app, pls do
    receive do
      { :pl_deliver, max_broadcasts, timeout } ->
        send app, { :beb_deliver, max_broadcasts, timeout }
        next id, pl, app, pls
    end
  end

  defp next id, pl, app, pls do
    receive do
      { :beb_broadcast, message } ->
        for { _, dest } <- pls, do:
          send pl, { :pl_send, id, dest, message }

      { :pl_deliver, from, message } ->
        send app, { :beb_deliver, from, message }
    end

    next id, pl, app, pls
  end

end # BEB
