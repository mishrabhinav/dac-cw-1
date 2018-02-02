# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule System3 do

  def main do
    max_broadcasts = 1000
    timeout = 3000
    num_peers = 5

    peers =
      case System.get_env("DOCKER") || "false" do
        "true" -> for i <- 1..num_peers, do: { i, Node.spawn(:"peer#{i}@peer#{i}.localdomain", Peer, :start, [i, self()]) }
        "false" -> for i <- 1..num_peers, do: { i, spawn(Peer, :start, [i, self()]) }
      end

    peer_bebs =
      for _ <- 1..num_peers do
        receive do
          { :response, id, pl, beb, app } -> { id, pl, beb, app }
        end
      end

    for { _, peer } <- peers, do:
      send peer, { :bind, peer_bebs }

    for { _, pl, _, _ } <- peer_bebs, do:
      send pl, { :pl_send, max_broadcasts, timeout }

  end # main

end # System3
