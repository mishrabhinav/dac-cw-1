defmodule DNS do

  def lookup(name) do
     addresses = :inet_res.lookup(name,:in,:a)
     {a, b, c, d} = hd(addresses)   # get octets for 1st ipv4 address
     :"#{a}.#{b}.#{c}.#{d}"
  end

  def my_ip_addr do
     {:ok, interfaces} = :inet.getif()    # get interfaces
     {address, _gateway, _mask}  = hd(interfaces) # get data for 1st interface
     {a, b, c, d} = address         # get octets for address
     "#{a}.#{b}.#{c}.#{d}"
  end

end # module ----------------
