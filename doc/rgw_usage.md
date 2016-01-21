# QuickStart - Use RGW
- [Manage user](#manage-user)
  - [radosgw-admin command list](#radosgw-admin-command-list)
  - [create user](#create-user)
  - [add Capabilities](#add-capabilities)
  - [get user info](#get-user-info)

- [Use s3cmd](#use-s3cmd)
  - [s3 concept](#s3-concept)
  - [s3cmd command list](#s3cmd-command-list)
  - [configure s3cmd for rgw](#configure-s3cmd-for-rgw)
  - [manage bucket](#manage-bucket)
  - [manage object](#manage-object)

- [Use swift](#use-swift)
  - [swift concept](#swift-concept)
  - [swift command list](#swift-command-list)
  - [configure swift for rgw](#configure-swift-for-rgw)
  - [manage container](#manage-container)
  - [manage object](#manage-object)

- [Use radosgw-admin](#use-radosgw-admin)
  - [radosgw-admin command list](#radosgw-admin-command-list)
  - [list bucket](#list-bucket)
  - [view bucket stats](#view-bucket-stats)

## Manage user
### radosgw-admin command list

```
// show command list for user
$ radosgw-admin --help | grep "^  user"
  user create                create a new user
  user modify                modify user
  user info                  get user info
  user rm                    remove user
  user suspend               suspend a user
  user enable                re-enable user after suspension
  user check                 check user info
  user stats                 show user stats as accounted by quota subsystem
```

### create user

```shell
$ radosgw-admin user create --uid=jimmy --display-name="Jimmy Xu" --email==xjimmyshcn@gmail.com
```

### add Capabilities

```shell
$ radosgw-admin caps add --uid=jimmy --caps="users=*"
$ radosgw-admin caps add --uid=jimmy --caps="buckets=*"
$ radosgw-admin caps add --uid=jimmy --caps="metadata=*"
$ radosgw-admin caps add --uid=jimmy --caps="zone=*"
```

### get user info

```shell
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
```

## Use s3cmd
### s3 concept
- Bucket
  - Object

### s3cmd command list

```
//show s3cmd command list
$ s3cmd --help | grep "^      s3cmd"
      s3cmd mb s3://BUCKET
      s3cmd rb s3://BUCKET
      s3cmd ls [s3://BUCKET[/PREFIX]]
      s3cmd la
      s3cmd put FILE [FILE...] s3://BUCKET[/PREFIX]
      s3cmd get s3://BUCKET/OBJECT LOCAL_FILE
      s3cmd del s3://BUCKET/OBJECT
      s3cmd rm s3://BUCKET/OBJECT
      s3cmd restore s3://BUCKET/OBJECT
      s3cmd sync LOCAL_DIR s3://BUCKET[/PREFIX] or s3://BUCKET[/PREFIX] LOCAL_DIR
      s3cmd du [s3://BUCKET[/PREFIX]]
      s3cmd info s3://BUCKET[/OBJECT]
      s3cmd cp s3://BUCKET1/OBJECT1 s3://BUCKET2[/OBJECT2]
      s3cmd modify s3://BUCKET1/OBJECT
      s3cmd mv s3://BUCKET1/OBJECT1 s3://BUCKET2[/OBJECT2]
      s3cmd setacl s3://BUCKET[/OBJECT]
      s3cmd setpolicy FILE s3://BUCKET
      s3cmd delpolicy s3://BUCKET
      s3cmd setcors FILE s3://BUCKET
      s3cmd delcors s3://BUCKET
      s3cmd payer s3://BUCKET
      s3cmd multipart s3://BUCKET [Id]
      s3cmd abortmp s3://BUCKET/OBJECT Id
      s3cmd listmp s3://BUCKET/OBJECT Id
      s3cmd accesslog s3://BUCKET
      s3cmd sign STRING-TO-SIGN
      s3cmd signurl s3://BUCKET/OBJECT <expiry_epoch|+expiry_offset>
      s3cmd fixbucket s3://BUCKET[/PREFIX]
      s3cmd ws-create s3://BUCKET
      s3cmd ws-delete s3://BUCKET
      s3cmd ws-info s3://BUCKET
      s3cmd expire s3://BUCKET
      s3cmd setlifecycle FILE s3://BUCKET
      s3cmd dellifecycle s3://BUCKET
      s3cmd cflist
      s3cmd cfinfo [cf://DIST_ID]
      s3cmd cfcreate s3://BUCKET
      s3cmd cfdelete cf://DIST_ID
      s3cmd cfmodify cf://DIST_ID
      s3cmd cfinvalinfo cf://DIST_ID[/INVAL_ID]
```

### configure s3cmd for rgw

```shell
$ s3cmd --configure
  ...
  Configuration saved to '/root/.s3cfg'

// modify host in .s3cfg
$ HOST_BASE=$(hostname):8800
$ sed -r -i "s/host_base =.*/host_base = ${HOST_BASE}/" /root/.s3cfg
$ sed -r -i "s/host_bucket =.*/host_bucket = %(bucket)s.${HOST_BASE}/" /root/.s3cfg

//(hostname is mini-ubuntu)
$ grep host_ /root/.s3cfg
  host_base = mini-ubuntu:8800
  host_bucket = %(bucket)s.mini-ubuntu:8800

// test config
$ s3cmd  --configure
  ...
  Test access with supplied credentials? [Y/n]
  Please wait, attempting to list all buckets...
  Success. Your access key and secret key worked fine :-)
  ...
```

### manage bucket

```shell
$ s3cmd mb s3://TEST
  Bucket 's3://TEST/' created

$ s3cmd ls
  2016-01-20 10:44  s3://TEST

$ s3cmd rb s3://TEST
  Bucket 's3://TEST/' removed
```

### manage object

```shell
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
```

## Use swift
### swift concept
- Account(`corresponding to a tenant`)
  - Container
    - Object

### swift command list

```
// show swift command list
$ swift --help | grep "^  <subcommand>" -A12
  <subcommand>
    delete               Delete a container or objects within a container.
    download             Download objects from containers.
    list                 Lists the containers for the account or the objects for a container.
    post                 Updates meta information for the account, container, or object; creates containers if not present.
    stat                 Displays information for the account, container, or object.
    upload               Uploads files or directories to the given container.
    capabilities         List cluster capabilities.
    tempurl              Create a temporary URL.
    auth                 Display auth related environment variables.
```

### configure swift for rgw

```
//create subuser
$ radosgw-admin subuser create --uid=jimmy --subuser=jimmy:swift --access=full --secret=aaa123aa --key-type=swift
```

### manage container

```
// create container
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa post test

// list container
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa list
test
TEST

// delete container
swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa delete test
test
```

### manage object

```
$ echo hello > hello.txt
//create object(upload file)
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa upload test hello.txt
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa upload test/t1/t2/ hello.txt
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa list test                       
  hello.txt
  t1/t2/
  t1/t2/hello.txt

//view file
$ curl http://127.0.0.1:8800/test/hello.txt
  <?xml version="1.0" encoding="UTF-8"?><Error><Code>AccessDenied</Code><RequestId>tx000000000000000000119-0056a099c2-8533-default</RequestId></Error>                                                       

//view default acl
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa stat test | grep ACL      
      Read ACL:
      Write ACL:

//set acl
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa post test -r '.r:*'

//view new acl
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa stat test | grep ACL      
      Read ACL: .r:*
      Write ACL:

//view file again
$ curl http://127.0.0.1:8800/test/hello.txt
  hello

//delete object
$ swift -V 1.0 -A http://127.0.0.1:8800/auth -U jimmy:swift -K aaa123aa delete test hello.txt
```

## Use radosgw-admin
### radosgw-admin command list

```
// show command list for user
radosgw-admin --help | grep "^  bucket"
  bucket list                list buckets
  bucket link                link bucket to specified user
  bucket unlink              unlink bucket from specified user
  bucket stats               returns bucket statistics
  bucket rm                  remove bucket
  bucket check               check bucket index
`
```

### list bucket

```json
$ radosgw-admin bucket list
  [
      "test1",
      "test"
  ]
```

### view bucket stats

```json
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
```
