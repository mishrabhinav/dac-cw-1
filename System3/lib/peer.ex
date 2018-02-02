# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do

  def start id, system do
    app = spawn App, :start, [id]
    pl = spawn PL, :start, [id]
    beb = spawn BEB, :start, [id]

    send system, { :response, id, pl, beb, app }

    receive do
      { :bind, peer_bebs } ->
        pls = Enum.map(peer_bebs, fn { id, pl, _, _ } -> { id, pl } end)
        send app, { :bind, beb, length(peer_bebs) }
        send pl,  { :bind, beb }
        send beb, { :bind, pl, app, pls }
    end
  end # start

end # Peer
