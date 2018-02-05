# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule PL do

  def start id, app do
    IO.puts ["\tPL at ", DNS.my_ip_addr()]

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
