# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
defmodule System2 do

  def main do
    IO.puts ["\tSystem at ", DNS.my_ip_addr()]

    max_broadcasts = if System.get_env("MAX_BROADCASTS") do
                       String.to_integer(System.get_env("MAX_BROADCASTS"))
                     else
                       1000
                     end
    timeout        = if System.get_env("TIMEOUT") do
                       String.to_integer(System.get_env("TIMEOUT"))
                     else
                       3000
                     end
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

    for { _, peer } <- peers, do:
      send peer, { :bind, peer_pls }

    for { _, pl } <- peer_pls, do:
      send pl, { :pl_send, max_broadcasts, timeout }

  end # main

end
