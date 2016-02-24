#!/bin/bash

echo "# build docker image: xjimmyshcn/ceph"
docker build -t xjimmyshcn/ceph .

HOST_IP=$(grep " $(route -n | awk '/UG/{print $NF}' ) " <(ip route) | grep  -v default | grep src | awk '{for(i=1;i<=NF;i++){if($i=="src"){print $(i+1)}}}' | head -n1)
PREFIX=$(grep " $(route -n | awk '/UG/{print $NF}' ) " <(ip route) | grep  -v default | grep src | awk '{print $1}'| head -n1)
cat <<EOF
HOST_IP: ${HOST_IP}
PREFIX:  ${PREFIX}
EOF

echo "# start single node ceph"
CMD_LINE="docker run -d --name=ceph-demo --privileged=true --net=host -v /etc/ceph:/etc/ceph -v /var/log/ceph:/var/log/ceph -v /dev:/dev -v /sys:/sys -e MON_IP=${HOST_IP} -e CEPH_NETWORK=${PREFIX} xjimmyshcn/ceph"
echo "cmd: ${CMD_LINE}"
${CMD_LINE}
