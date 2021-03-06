# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do

  def start id, system, lpl_reliability do
    IO.puts ["\tPeer at ", DNS.my_ip_addr()]

    app = spawn App, :start, [id]
    lpl = spawn LPL, :start, [id, lpl_reliability]
    beb = spawn BEB, :start, [id]

    send system, { :response, id, lpl, beb, app }

    receive do
      { :bind, peer_bebs } ->
        lpls = Enum.map(peer_bebs, fn { id, lpl, _, _ } -> { id, lpl } end)
        send app, { :bind, beb, length(peer_bebs) }
        send lpl,  { :bind, beb }
        send beb, { :bind, lpl, app, lpls }
    end
  end # start

end # Peer
