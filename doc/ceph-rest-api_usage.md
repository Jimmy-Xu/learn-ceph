# QuickStart - Use ceph-rest-api

```
$ curl 127.0.0.1:5500/api/v0.1/health
  HEALTH_WARN too many PGs per OSD (2152 > max 300); mon.mini-ubuntu low disk space

$ curl 127.0.0.1:5500/api/v0.1/osd/tree
  ID WEIGHT  TYPE NAME            UP/DOWN REWEIGHT PRIMARY-AFFINITY
  -1 1.00000 root default                                           
  -2 1.00000     host mini-ubuntu                                   
   0 1.00000         osd.0             up  1.00000          1.00000
```
