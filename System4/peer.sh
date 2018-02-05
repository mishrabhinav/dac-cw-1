install_ex()
{
	echo "Installing elixir..."
	sudo apt-get -qq update
	sudo apt-get -qq -y install elixir || exit 1
}

echo "Checking requirements..."
command -v elixir >/dev/null 2>&1 || { echo "Missing elixir."; install_ex; }

git clone https://github.com/mishrabhinav/dac-cw-1.git
cd dac-cw-1/System4

IP=`ifconfig eth0 | sed -n '2s/[^:]*:\([^ ]*\).*/\1/p'`

echo "Starting elixir node..."
elixir --name peer4@$IP --cookie darthvader --detached -S mix run --no-halt -e System4.main
echo "Running at peer4@$IP"
