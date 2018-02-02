defmodule Peer do

  def start do
    app = spawn App, :start, []
    pl = spawn PL, :start, []

    receive do
      {:request, id, system} ->
        send app, { :init, id, pl }
        send pl, { :init, id, app }
        send system, { :response, id, pl }
    end
  end

end
