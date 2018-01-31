# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule System1 do

  def main do
    max_broadcasts = 1000
    timeout = 3000
    num_peers = 5

    peers = for _ <- 1..num_peers, do: spawn(Peer, :start, [])

    for id <- 1..num_peers, do:
      send Enum.at(peers, id - 1), {:bind, id-1, peers}

    # Send message to each peer
    for peer <- peers, do:
      send peer, {:broadcast, max_broadcasts, timeout}

  end # main

end # System1
