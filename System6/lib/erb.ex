# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule ERB do

  def start id do
    receive do
      { :bind, beb, app } ->
        wait_for_broadcast id, beb, app
    end
  end # start

  defp wait_for_broadcast id, beb, app do
    receive do
      { :beb_deliver, max_broadcasts, timeout } ->
        send app, { :erb_deliver, max_broadcasts, timeout }
        next id, beb, app, MapSet.new, 0
    end
  end # wait_for_broadcast

  defp next id, beb, app, delivered, seq do
    receive do
      { :erb_broadcast, message } ->
        send beb, { :beb_broadcast, { :erb_data, id, message, seq } }
        next id, beb, app, delivered, seq+1
      { :beb_deliver, _, { :erb_data, sender, message, g_seq } = erb_m } ->
        if MapSet.member? delivered, { sender, message, g_seq } do
          next id, beb, app, delivered, seq
        else
          send app, { :erb_deliver, sender, message }
          send beb, { :beb_broadcast, erb_m }
          next id, beb, app, MapSet.put(delivered, { sender, message, g_seq }), seq
        end
    end
  end # next

end
