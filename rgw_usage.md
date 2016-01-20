QuickStart - Use RGW
===================================

Manage user
----------------------------

### create user

    $ radosgw-admin user create --uid=jimmy --display-name="Jimmy Xu" --email==xjimmyshcn@gmail.com

### add Capabilities

    $ radosgw-admin caps add --uid=jimmy --caps="users=*"
    $ radosgw-admin caps add --uid=jimmy --caps="buckets=*"
    $ radosgw-admin caps add --uid=jimmy --caps="metadata=*"
    $ radosgw-admin caps add --uid=jimmy --caps="zone=*"

### get user info

    $ radosgw-admin user info --uid=jimmy | jq ".keys,.caps"
      [
        {
          "secret_key": "aloXl3pB0pKgj2g33EnKMWfPiOlTKwz0wdLhIC5n",
          "access_key": "0QM6VTV44WGX8WNWKLPB",
          "user": "jimmy"
        }
      ]
      [
        { "perm": "*", "type": "buckets" },
        { "perm": "*", "type": "metadata" },
        { "perm": "*", "type": "users" },
        { "perm": "*", "type": "zone" }
      ]


Config s3cmd for RGW
----------------------------

### configure

    $ s3cmd --configure
      ...
      Configuration saved to '/root/.s3cfg'


### modify /root/.s3cfg

    $ HOST_BASE=$(hostname):8800
    $ sed -r -i "s/host_base =.*/host_base = ${HOST_BASE}/" /root/.s3cfg
    $ sed -r -i "s/host_bucket =.*/host_bucket = %(bucket)s.${HOST_BASE}/" /root/.s3cfg

    #hostname is mini-ubuntu
    $ grep host_ /root/.s3cfg
      host_base = mini-ubuntu:8800
      host_bucket = %(bucket)s.mini-ubuntu:8800


### test connect rgw

    $ s3cmd  --configure
      ...
      Test access with supplied credentials? [Y/n]
      Please wait, attempting to list all buckets...
      Success. Your access key and secret key worked fine :-)
      ...


use s3cmd
----------------------------

### manage bucket

    $ s3cmd mb s3://TEST
      Bucket 's3://TEST/' created

    $ s3cmd ls
      2016-01-20 10:44  s3://TEST

    $ s3cmd rb s3://TEST
      Bucket 's3://TEST/' removed

### manage file

    $ echo hello > hello.txt

    $ s3cmd put hello.txt s3://TEST/hello.txt
      'hello.txt' -> 's3://TEST/hello.txt'  [1 of 1]
       6 of 6   100% in    0s   532.15 B/s  done

    $ s3cmd ls s3://TEST
      2016-01-20 10:54         6   s3://TEST/hello.txt

    $ s3cmd setacl s3://TEST/hello.txt  --acl-public
      s3://TEST/hello.txt: ACL set to Public  [1 of 1]

    $ curl http://127.0.0.1:8800/TEST/hello.txt
      hello

    $ s3cmd del s3://TEST/hello.txt
      delete: 's3://TEST/hello.txt'


Use radosgw-admin
----------------------------

    $ radosgw-admin bucket stats
     [
         "TEST",
         {
             "bucket": "TEST",
             "pool": ".rgw.buckets",
             "index_pool": ".rgw.buckets.index",
             "id": "default.4108.6",
             "marker": "default.4108.6",
             "owner": "jimmy",
             "ver": "0#13",
             "master_ver": "0#0",
             "mtime": "2016-01-20 10:49:09.000000",
             "max_marker": "0#",
             "usage": {
                 "rgw.main": {
                     "size_kb": 5,
                     "size_kb_actual": 12,
                     "num_objects": 2
                 }
             },
             "bucket_quota": {
                 "enabled": false,
                 "max_size_kb": -1,
                 "max_objects": -1
             }
         }
     ]

    $ radosgw-admin bucket list
       [
           "TEST"
       ]
