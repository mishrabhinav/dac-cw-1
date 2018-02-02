defmodule PL do

  def start id, app do
    receive do
      { :pl_send, max_broadcasts, timeout } ->
        send app, { :pl_deliver, max_broadcasts, timeout }
        next id, app
    end
  end

  defp next id, app do
    receive do
      { :pl_send, to_pid, message } ->
        send to_pid, { :pl_deliver, id, message }

      { :pl_deliver, from, message } ->
        send app, { :pl_deliver, from, message }
    end

    next id, app
  end

end
