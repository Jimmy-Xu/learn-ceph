# QuickStart - Use ceph-rest-api
## get the status of the cluster

```shell
$ curl 127.0.0.1:5500/api/v0.1/health
  HEALTH_WARN too many PGs per OSD (2152 > max 300); mon.mini-ubuntu low disk space
```

## get json data of status

```json
$ curl -s -H "Accept: application/json" 127.0.0.1:5500/api/v0.1/health  | jq .
  {
    "output": {
      "summary": [
        {
          "summary": "too many PGs per OSD (2152 > max 300)",
          "severity": "HEALTH_WARN"
        },
        {
          "summary": "mon.mini-ubuntu low disk space",
          "severity": "HEALTH_WARN"
        }
      ],
      "overall_status": "HEALTH_WARN",
      "health": {
        "health_services": [
          {
            "mons": [
              {
                "store_stats": {
                  "bytes_sst": 0,
                  "bytes_misc": 19440022,
                  "last_updated": "0.000000",
                  "bytes_log": 213048,
                  "bytes_total": 19653070
                },
                "health_detail": "low disk space",
                "last_updated": "2016-01-21 10:39:08.269740",
                "name": "mini-ubuntu",
                "avail_percent": 14,
                "kb_total": 47929224,
                "kb_avail": 7101300,
                "health": "HEALTH_WARN",
                "kb_used": 38370172
              }
            ]
          }
        ]
      },
      "timechecks": {
        "round": 0,
        "epoch": 1,
        "round_status": "finished"
      },
      "detail": []
    },
    "status": "OK"
  }
```

```
$ curl 127.0.0.1:5500/api/v0.1/osd/tree
  ID WEIGHT  TYPE NAME            UP/DOWN REWEIGHT PRIMARY-AFFINITY
  -1 1.00000 root default                                           
  -2 1.00000     host mini-ubuntu                                   
   0 1.00000         osd.0             up  1.00000          1.00000
```
