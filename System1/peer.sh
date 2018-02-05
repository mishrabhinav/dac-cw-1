install_ex()
{
	echo "Installing elixir..."
	sudo apt-get -qq update
	sudo apt-get -qq -y install elixir || exit 1
}

echo "Checking requirements..."
command -v elixir >/dev/null 2>&1 || { echo "Missing elixir."; install_ex; }

git clone https://github.com/mishrabhinav/dac-cw-1.git
cd dac-cw-1/System1

IP=`ifconfig eth0 | sed -n '2s/[^:]*:\([^ ]*\).*/\1/p'`

echo "Starting elixir node..."
elixir --name peer1@$IP --cookie darthvader --detached -S mix run --no-halt
echo "Running at peer1@$IP"
