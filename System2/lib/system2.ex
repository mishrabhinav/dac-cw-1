defmodule System2 do

  def main do
    max_broadcasts = 1000
    timeout = 3000
    num_peers = 5

    peers =
      case System.get_env("DOCKER") || "false" do
        "true" -> for i <- 1..num_peers, do: { i, Node.spawn(:"peer#{i}@peer#{i}.localdomain", Peer, :start, [i, self()]) }
        "false" -> for i <- 1..num_peers, do: { i, spawn(Peer, :start, [i, self()]) }
      end

    peer_pls =
      for _ <- 1..num_peers do
        receive do
          { :response, id, pl } -> { id, pl }
        end
      end

    for { id, peer } <- peers, do:
      send peer, { :bind, peer_pls }

    for { id, pl } <- peer_pls, do:
      send pl, { :pl_send, max_broadcasts, timeout }

  end # main

end
