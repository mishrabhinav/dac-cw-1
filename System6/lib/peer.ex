# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do

  def start id, system, lpl_drop_rate, kill_timeout do
    app = spawn App, :start, [id]
    lpl = spawn LPL, :start, [id, lpl_drop_rate]
    beb = spawn BEB, :start, [id]
    erb = spawn ERB, :start, [id]

    send system, { :response, id, lpl, beb, app, erb }

    receive do
      { :bind, peer_metadata } ->
        lpls = Enum.map(peer_metadata, fn { id, lpl, _, _, _ } -> { id, lpl } end)

        send lpl, { :bind, beb }
        send beb, { :bind, lpl, erb, lpls }
        send erb, { :bind, beb, app }
        send app, { :bind, erb, length(peer_metadata) }
    end

    if id == 3, do:
      kill kill_timeout, app, lpl, beb, erb
  end # start

  defp kill timeout, app, lpl, beb, erb do
    Process.sleep(timeout)
    Process.exit(app, :kill)
    Process.exit(erb, :kill)
    Process.exit(beb, :kill)
    Process.exit(lpl, :kill)
    Process.exit(self(), :kill)
  end

end # Peer
