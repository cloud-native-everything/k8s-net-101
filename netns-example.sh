docker run -dt --rm --name netns-test1 --network none pinrojas/net-test:v0.3
docker run -dt --rm --name netns-test2 --network none pinrojas/net-test:v0.3

rm -rf /var/run/netns/netns-test1
rm -rf /var/run/netns/netns-test2

pid1=$(docker inspect -f '{{.State.Pid}}' netns-test1)
pid2=$(docker inspect -f '{{.State.Pid}}' netns-test2)

sudo ln -sf /proc/$pid1/ns/net /var/run/netns/netns-test1
sudo ln -sf /proc/$pid2/ns/net /var/run/netns/netns-test2

sudo ip link add veth1 type veth peer name veth2
sudo ip link set veth1 netns netns-test1
sudo ip link set veth2 netns netns-test2
sudo ip netns exec netns-test1 ip link set veth1 name eth0
sudo ip netns exec netns-test2 ip link set veth2 name eth0

sudo ip netns exec netns-test1 ip link set eth0 up
sudo ip netns exec netns-test2 ip link set eth0 up

sudo ip netns exec netns-test1 ip addr add 1.1.1.1/30 dev eth0
sudo ip netns exec netns-test2 ip addr add 1.1.1.2/30 dev eth0
