# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do

  def start id, system, lpl_drop_rate, kill_timeout do
    app = spawn App, :start, [id]
    lpl = spawn LPL, :start, [id, lpl_drop_rate]
    beb = spawn BEB, :start, [id]

    send system, { :response, id, lpl, beb, app }

    receive do
      { :bind, peer_bebs } ->
        lpls = Enum.map(peer_bebs, fn { id, lpl, _, _ } -> { id, lpl } end)
        send app, { :bind, beb, length(peer_bebs) }
        send lpl,  { :bind, beb }
        send beb, { :bind, lpl, app, lpls }
    end

    if id == 3, do:
      kill kill_timeout, app, lpl, beb
  end # start

  defp kill timeout, app, lpl, beb do
    Process.sleep(timeout)
    Process.exit(app, :kill)
    Process.exit(beb, :kill)
    Process.exit(lpl, :kill)
    Process.exit(self(), :kill)
  end

end # Peer
