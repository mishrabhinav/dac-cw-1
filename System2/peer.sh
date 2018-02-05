install_ex()
{
	echo "Installing elixir..."
	sudo apt-get -qq update
	sudo apt-get -qq -y install elixir || exit 1
}

echo "Checking requirements..."
command -v elixir >/dev/null 2>&1 || { echo "Missing elixir."; install_ex; }

git clone https://github.com/mishrabhinav/dac-cw-1.git
cd dac-cw-1/System2

IP=`ifconfig eth0 | sed -n '2s/[^:]*:\([^ ]*\).*/\1/p'`

echo "Starting elixir node..."
elixir --name peer2@$IP --cookie darthvader --detached -S mix run --no-halt -e System2.main
echo "Running at peer2@$IP"
