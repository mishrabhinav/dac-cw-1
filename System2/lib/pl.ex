defmodule PL do

  def start do
    receive do
      { :init, id, app } ->
        wait_for_broadcast id, app
    end
  end

  defp wait_for_broadcast id, app do
    receive do
      { :broadcast, max_broadcasts, timeout } ->
        send app, { :broadcast, max_broadcasts, timeout }
        next id, app
    end
  end

  defp next id, app do
    receive do
      { :pl_send, to_pid, message } ->
        send to_pid, { :pl_deliver, id, message }

      { :pl_deliver, from, message } ->
        IO.puts from
        send app, { :pl_deliver, from, message }
    end

    next id, app
  end

end
