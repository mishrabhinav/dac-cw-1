# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)

defmodule System5 do

  def main do
    init :local, []
  end # main

  def main_docker do
    init :docker, []
  end # main_docker

  def main_net do
    domains =
      File.stream!("/etc/ips.txt")
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list

    init :net, domains
  end # main_net

  defp init env, domains do
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
    lpl_drop_rate  = if System.get_env("LPL_DROP_RATE") do
                       String.to_integer(System.get_env("LPL_DROP_RATE"))
                     else
                       33
                     end
    kill_timeout   = if System.get_env("KILL_TIMEOUT") do
                       String.to_integer(System.get_env("KILL_TIMEOUT"))
                     else
                       5
                     end
    num_peers = 5

    peers = for i <- 1..num_peers do
      case env do
        :net    -> { i, Node.spawn(:"peer5@#{Enum.at(domains, i - 1)}", Peer, :start, [i, self(), lpl_drop_rate, kill_timeout])}
        :docker -> { i, Node.spawn(:"peer#{i}@peer#{i}.localdomain", Peer, :start, [i, self(), lpl_drop_rate, kill_timeout])}
        :local  -> { i, spawn(Peer, :start, [i, self(), lpl_drop_rate, kill_timeout])}
      end
    end

    peer_bebs =
      for _ <- 1..num_peers do
        receive do
          { :response, id, lpl, beb, app } -> { id, lpl, beb, app }
        end
      end

    for { _, peer } <- peers, do:
      send peer, { :bind, peer_bebs }

    for { _, lpl, _, _ } <- peer_bebs, do:
      send lpl, { :pl_send, max_broadcasts, timeout }

  end # main

end
