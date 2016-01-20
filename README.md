Learn ceph by ceph/demo
=====================================


Prepare image
----------------------------

    $ docker pull ceph/demo


Build image
----------------------------

    $ docker build -t xjimmyshcn/ceph .


ENV(default value)
----------------------------

    CLUSTER = ceph
    RGW_NAME = $(hostname -s)
    MON_NAME = $(hostname -s)
    RGW_CIVETWEB_PORT = 8800  #ceph-rest-api port
    RADOSGW_PORT = 5500       #rgw server port
    MON_IP = ${host_ip}


Start ceph-demo
----------------------------

    $ HOST_IP=$(grep " $(route -n | awk '/UG/{print $NF}' ) " <(ip route) | grep  -v default | grep src | awk '{for(i=1;i<=NF;i++){if($i=="src"){print $(i+1)}}}')

    $ PREFIX=$(grep " $(route -n | awk '/UG/{print $NF}' ) " <(ip route) | grep  -v default | grep src | awk '{print $1}')

    $ docker run -d --name=ceph-demo --privileged=true --net=host -v /etc/ceph:/etc/ceph -v /dev:/dev -v /sys:/sys -e MON_IP=${HOST_IP} -e CEPH_NETWORK=${PREFIX} xjimmyshcn/ceph


Check service status
----------------------------

### check processes

    $ docker exec -it ceph-demo ps -ef
      UID        PID  PPID  C STIME TTY          TIME CMD
      root         1     0  1 10:11 ?        00:00:00 /usr/bin/python /usr/bin/ceph --cluster ceph -w
      root        20     1  1 10:11 ?        00:00:00 ceph-mon --cluster ceph -i mini-ubuntu --public-addr 192.168.1.137
      root       179     1  7 10:11 ?        00:00:00 ceph-osd --cluster ceph -i 0 -k /var/lib/ceph/osd/ceph-0/keyring
      root       389     1  0 10:11 ?        00:00:00 ceph-mds --cluster ceph -i 0
      root       443     1  1 10:11 ?        00:00:00 radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway -k /var/lib/ceph/radosgw/mini-ubuntu/keyring --rgw-socket-path= --rgw-frontends=civetweb port=8800
      root       446     1  3 10:11 ?        00:00:00 /usr/bin/python /usr/bin/ceph-rest-api --cluster ceph -n client.admin

### check ports

    $ docker exec -it ceph-demo netstat -tnopl | grep -v " - "
      Active Internet connections (only servers)
      Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name Timer
      tcp        0      0 192.168.1.137:6801      0.0.0.0:*               LISTEN      179/ceph-osd     off (0.00/0/0)
      tcp        0      0 192.168.1.137:6802      0.0.0.0:*               LISTEN      179/ceph-osd     off (0.00/0/0)
      tcp        0      0 192.168.1.137:6803      0.0.0.0:*               LISTEN      179/ceph-osd     off (0.00/0/0)
      tcp        0      0 192.168.1.137:6804      0.0.0.0:*               LISTEN      179/ceph-osd     off (0.00/0/0)
      tcp        0      0 192.168.1.137:6805      0.0.0.0:*               LISTEN      389/ceph-mds     off (0.00/0/0)
      tcp        0      0 0.0.0.0:5500            0.0.0.0:*               LISTEN      446/python       off (0.00/0/0)
      tcp        0      0 0.0.0.0:8800            0.0.0.0:*               LISTEN      443/radosgw      off (0.00/0/0)
      tcp        0      0 192.168.1.137:6789      0.0.0.0:*               LISTEN      20/ceph-mon      off (0.00/0/0)


Check rgw service
----------------------------

    $ xmllint --format <(curl -s http://127.0.0.1:8800)
      <?xml version="1.0" encoding="UTF-8"?>
      <ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
        <Owner>
          <ID>anonymous</ID>
          <DisplayName/>
        </Owner>
        <Buckets/>
      </ListAllMyBucketsResult>


Usage
----------------------------

- [Use RGW](rgw_usage.md)
- [Use RBD](rbd_usage.md)
