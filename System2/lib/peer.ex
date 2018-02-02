defmodule Peer do

  def start do
    app = spawn App, :start, []
    pl = spawn PL, :start, []

    receive do
      { :request, id, system, peers } ->
        send app, { :init, id, pl, peers }
        send pl, { :init, id, app }
        send system, { :response, id, pl, app }
    end
  end

end
