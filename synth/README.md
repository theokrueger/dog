https://github.com/parallaxsw/OpenSTA

cd OpenSTA
docker build --file Dockerfile.ubuntu22.04 --tag opensta_ubuntu22.04 .

sh script.sh N clk

NEED IN DIRECTORY
scp vlsi:/ece558_658/gsclib045/slow.lib .
scp vlsi:/ece558_658/lib/slow_vdd1v0_basicCells.v
