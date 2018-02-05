# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule System1 do

  def main do
    init :local, []
  end # main

  def main_docker do
    init :docker, []
  end # main

  def main_net do
    domains =
      File.stream!("../ips.txt")
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list

    init :net, domains
  end # main

  defp init env, domains do
    IO.puts ["\tSystem at ", DNS.my_ip_addr()]
    #max_broadcasts = String.to_integer(System.get_env("MAX_BROADCASTS") || "") || 1000
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

    peers = for i <- 1..num_peers do
      case env do
        :net    -> Node.spawn(:"peer1@#{Enum.at(domains, i - 1)}", Peer, :start, [])
        :docker -> Node.spawn(:"peer#{i}@peer#{i}.localdomain", Peer, :start, [])
        :local  -> spawn(Peer, :start, [])
      end
    end

    for id <- 1..num_peers, do:
      send Enum.at(peers, id - 1), {:bind, id-1, peers}

    # Send message to each peer
    for peer <- peers, do:
      send peer, {:broadcast, max_broadcasts, timeout}

  end # init

end # System1
