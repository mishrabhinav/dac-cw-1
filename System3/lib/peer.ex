# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule Peer do

  def start id, system do
    app = spawn App, :start, [id]
    pl = spawn PL, :start, [id, app]

    send system, { :response, id, pl }

    receive do
      { :bind, peer_pls } ->
        send app, { :bind, peer_pls }
    end
  end

end
