defmodule PL do

  def start do
    receive do
      { :init, id, app } ->
        bind_pls id, app
    end
  end

  defp bind_pls id, app do
    receive do
      { :bind, peer_metadata } ->
        wait_for_broadcast id, app, peer_metadata
    end
  end

  defp wait_for_broadcast id, app, peer_metadata do
    receive do
      { :broadcast, max_broadcasts, timeout } ->
        send app, { :broadcast, max_broadcasts, timeout }
        next id, app, peer_metadata
    end
  end

  defp next id, app, peers do
    receive do
      { :pl_send, to, message } ->
        send_message id, to, message, peers

      { :pl_deliver, from, message } ->
        send app, { :pl_deliver, from, message }
    end
    next id, app, peers
  end

  defp send_message self_id, to_id, message, peers do
    for { peer_id, pl } <- peers do
      if peer_id == to_id do
        send pl, { :pl_deliver, self_id, message }
      end
    end
  end


end
