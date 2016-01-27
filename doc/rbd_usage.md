# QuickStart - Use RBD
- [Manage pool](#manage-pool)
  - [create new pool](#create-new-pool)
  - [list pool](#list-pool)
  - [show pool info](#show-pool-info)
  - [delete pool](#delete-pool)

- [Manage image](#manage-image)
  - [create new image in pool](#create-new-image-in-pool)
  - [list image](#list-image)
  - [get image info](#get-image-info)
  - [delete image](#delete-image)
  - [expand image size](#expand-image-size)
  - [shrink image size](#shrink-image-size)
  - [map image to a block device](#map-image-to-a-block-device)
  - [show the rbd images mapped](#show-the-rbd-images-mapped)
  - [build filesystem](#build-filesystem)
  - [mount rbd0](#mount-rbd0)
  - [umount rbd0](#umount-rbd0)
  - [unmap a rbd device that was mapped by the kernel](#unmap-a-rbd-device-that-was-mapped-by-the-kernel)

- [Manage snapshot](#manage-snapshot)
  - [create rbd snapshot](#create-rbd-snapshot)
  - [rollback rbd snapshot](#rollback-rbd-snapshot)
  - [delete rbd snapshot](#delete-rbd-snapshot)
  - [protect rbd snapshot](#protect-rbd-snapshot)
  - [clone image](#clone-image)
  - [fill clone with parent data](#fill-clone-with-parent-data)

## Manage pool

```shell
// show command list for pool
$ ceph osd pool --help | grep "^osd pool"
  osd pool create <poolname> <int[0-]>     create pool
  osd pool delete <poolname> {<poolname>}  delete pool
  osd pool get <poolname> size|min_size|   get pool parameter <var>
  osd pool get-quota <poolname>            obtain object or byte limits for pool
  osd pool ls {detail}                     list pools
  osd pool mksnap <poolname> <snap>        make snapshot <snap> in <pool>
  osd pool rename <poolname> <poolname>    rename <srcpool> to <destpool>
  osd pool rmsnap <poolname> <snap>        remove snapshot <snap> from <pool>
  osd pool set <poolname> size|min_size|   set pool parameter <var> to <val>
  osd pool set-quota <poolname> max_       set object or byte limit on pool
  osd pool stats {<name>}                  obtain stats from all pools, or from
```

### create new pool

```shell
// create pool in default pool 'rbd'
$ ceph osd pool create test_pool 1024
  pool 'test_pool' created
```

> rbd is the default pool, rbd cli use this pool by default

### list pool

```shell
$ ceph osd pool ls | grep test_pool
or
$ rados lspools | grep test_pool
  test_pool
```

### show pool info

```shell
$ ceph osd pool get test_pool all     
  size: 1
  min_size: 1lsm
  crash_replay_interval: 0
  pg_num: 1024
  pgp_num: 1024
  crush_ruleset: 0
  hashpspool: true
  nodelete: false
  nopgchange: false
  nosizechange: false
  write_fadvise_dontneed: false
  noscrub: false
  nodeep-scrub: false
  use_gmt_hitset: 1
  auid: 0
  min_write_recency_for_promote: 0
  fast_read: 0
```

### delete pool

```shell
$ ceph osd pool delete test_pool test_pool --yes-i-really-really-mean-it
  pool 'test_pool' removed
```

## Manage image
> There are two format to describe an image  

- format 1  

  `--pool <pool_name> --image <image_name>`

- format 2  

  `-- <pool_name>/<image_name>`

### create new image in pool

```shell
// create rbd in pool 'test_pool'
$ rbd create test_image --pool test_pool --size 1024
or
$ rbd create --pool test_pool --image test_image1 --size 1024
or
$ rbd create test_pool/test_image2 --size 1024
```

### list image

```shell
$ rbd ls test_pool
  test_image
  test_image1
  test_image2
or
$ rados ls -p test_pool
  rbd_directory
  rbd_header.85807e4b651
  rbd_data.85807e4b651.00000000000000e0
  rbd_data.85807e4b651.0000000000000001
  rbd_data.85807e4b651.0000000000000040
  rbd_data.85807e4b651.0000000000000003
  rbd_header.85c82d4adf71
  rbd_data.85807e4b651.00000000000000f9
  rbd_id.test_image1
  rbd_data.85807e4b651.0000000000000042
  rbd_data.85807e4b651.0000000000000020
  rbd_data.85807e4b651.00000000000000a0
  rbd_data.85807e4b651.0000000000000021
  rbd_data.85807e4b651.0000000000000060
  rbd_data.85807e4b651.0000000000000004
  rbd_header.85c9730c3b4a
  rbd_data.85807e4b651.0000000000000043
  rbd_data.85807e4b651.0000000000000041
  rbd_id.test_image2
  rbd_data.85807e4b651.0000000000000022
  rbd_data.85807e4b651.0000000000000002
  rbd_id.test_image
  rbd_data.85807e4b651.0000000000000000
  rbd_data.85807e4b651.0000000000000023
```

### get image info

```shell
$ rbd info test_pool/test_image
  rbd image 'test_image':
      size 1024 MB in 256 objects
      order 22 (4096 kB objects)
      block_name_prefix: rbd_data.85807e4b651
      format: 2
      features: layering
      flags:
```

### delete image

```shell
$ rbd rm test_pool/test_image1                      
  Removing image: 100% complete...done.

$ rbd rm test_pool/test_image2
  Removing image: 100% complete...done.
```

### expand image size

```shell
$ rbd resize test_pool/test_image --size 2000
  Resizing image: 100% complete...done.

$ rbd info test_pool/test_image
  rbd image 'test_image':
      size 2000 MB in 500 objects
      order 22 (4096 kB objects)
      block_name_prefix: rbd_data.85807e4b651
      format: 2
      features: layering
      flags:
```

### shrink image size

```shell
$ rbd resize test_pool/test_image --size 1000 --allow-shrink
  Resizing image: 100% complete...done.

$ rbd info test_pool/test_image
  rbd image 'test_image':
      size 1000 MB in 250 objects
      order 22 (4096 kB objects)
      block_name_prefix: rbd_data.85807e4b651
      format: 2
      features: layering
      flags:
```

### map image to a block device

```shell
$ rbd map test_image --pool test_pool
  /dev/rbd0

//FAQ 1: 
modinfo: ERROR: Module alias rbd not found.
need load rbd module in Host OS

//FAQ 2: 
libkmod: ERROR ../libkmod/libkmod.c:556 kmod_search_moddep: could not open moddep file '/lib/modules/3.19.0-25-generic/modules.dep.bin'
modinfo: ERROR: Module alias rbd not found.
modprobe: ERROR: ../libkmod/libkmod.c:556 kmod_search_moddep() could not open moddep file '/lib/modules/3.19.0-25-generic/modules.dep.bin'
rbd: failed to load rbd kernel module (1)
rbd: sysfs write failed
rbd: map failed: (2) No such file or directory

//Solution:
$ sudo modprobe rbd
$ lsmod | grep rbd
  rbd                    68638  0
  libceph               239089  1 rbd

//FAQ 2: rbd: map failed: (30) Read-only file system
  need `--privileged` parameter when run ceph-demo container
```

### show the rbd images mapped

```shell
$ rbd showmapped
  id pool      image      snap device    
  0  test_pool test_image -    /dev/rbd0
```

### build filesystem

```shell
// make fs on /dev/rbd0
$ mkfs.ext4 /dev/rbd0
  ...
  Writing superblocks and filesystem accounting information: done

FAQ 1: Could not stat /dev/rbd0 --- No such file or directory
  need `-v /dev:/dev -v /sys:/sys` parameter when run ceph-demo container

// check
$ parted -l | grep "/dev/rbd0" -A5
  Disk /dev/rbd0: 1049MB
  Sector size (logical/physical): 512B/512B
  Partition Table: loop
  Number  Start  End     Size    File system  Flags
   1      0.00B  1049MB  1049MB  ext4
```

### mount rbd0

```shell
$ mkdir -p /mnt/test
$ mount /dev/rbd0 /mnt/test

$ df -hT | grep rbd0
  /dev/rbd0      ext4      969M  1.3M  902M   1% /mnt/test
```

### umount rbd0

```shell
$ umount /dev/rbd0
or
$ umount /mnt/test

$ df -hT | grep rbd0
```

### unmap a rbd device that was mapped by the kernel

```shell
$ rbd unmap /dev/rbd0

$ rbd showmapped
```

## Manage snapshot

```
// show command list for pool
$ rbd snap --help | grep "^  snap"
  snap ls <image-spec>                        dump list of image snapshots
  snap create <snap-spec>                     create a snapshot
  snap rollback <snap-spec>                   rollback image to snapshot
  snap rm <snap-spec>                         deletes a snapshot
  snap purge <image-spec>                     deletes all snapshots
  snap protect <snap-spec>                    prevent a snapshot from being deleted
  snap unprotect <snap-spec>                  allow a snapshot to be deleted
```

> There are two format to describe a snapshot  

- format 1  

  `--pool <pool_name> --image <image_name> --snap <snapshot_name>`

- format 2  

  `-- <pool_name>/<image_name>@<snapshot_name>`

### create rbd snapshot
> no need umount device before create snap

```shell
$ mount /dev/rbd0 /mnt/test
$ df -h | grep rbd0
  /dev/rbd0       969M  1.3M  902M   1% /mnt/test

// create test_snap_1
$ echo 1 >/mnt/test/hello.txt
$ rbd snap create --pool test_pool --image test_image --snap test_snap_1

// create test_snap_2
$ echo 2 >/mnt/test/hello.txt
$ rbd snap create test_pool/test_image@test_snap_2

$ rbd snap ls test_pool/test_image
  SNAPID NAME           SIZE
      14 test_snap_1 1000 MB
      15 test_snap_2 1000 MB
```

### rollback rbd snapshot

```shell
// rollback to test_snap_1
$ echo 3 >/mnt/test/hello.txt
$ umount /dev/rbd0
$ rbd snap rollback --pool test_pool --image test_image --snap test_snap_1
  Rolling back to snapshot: 100% complete...done.
$ mount /dev/rbd0 /mnt/test
$ cat /mnt/test/hello.txt
  1

// rollback to test_snap_2
$ echo 3 >/mnt/test/hello.txt
$ umount /dev/rbd0
$ rbd snap rollback test_pool/test_image@test_snap_2
  Rolling back to snapshot: 100% complete...done.
$ mount /dev/rbd0 /mnt/test
$ cat /mnt/test/hello.txt
  2
```

### delete rbd snapshot

```shell
$ rbd snap ls test_pool/test_image
  SNAPID NAME           SIZE
      14 test_snap_1 1000 MB
      15 test_snap_2 1000 MB

// delete one shapshot of a image
$ rbd snap rm test_pool/test_image@test_snap_1
$ rbd snap ls test_pool/test_image            
  SNAPID NAME           SIZE
      15 test_snap_2 1000 MB

// deletes all snapshots of a image
$ rbd snap purge test_pool/test_image
  Removing all snapshots: 100% complete...done.
$ rbd snap ls test_pool/test_image
```

### protect rbd snapshot

```shell
// create a test snapshot
$ rbd snap create test_pool/test_image@test_snap_protected

// protect snapshot
$ rbd snap protect test_pool/test_image@test_snap_protected
$ rbd snap ls test_pool/test_image
  SNAPID NAME                   SIZE
      18 test_snap_protected 1000 MB

// try to delete snapshot
$ rbd snap rm test_pool/test_image@test_snap_protected
  rbd: snapshot 'test_snap_protected' is protected from removal.2016-01-21 05:47:22.621526 7fdc0a04b7c0 -1 librbd: removing snapshot from header failed: (16) Device or resource busy

// try to delete all snapshots of a image
$ rbd snap purge test_pool/test_image
  Removing all snapshots: 0% complete...failed.
  rbd: snapshot 'test_snap_protected' is protected from removal.

// unprotect snapshot
$ rbd snap unprotect test_pool/test_image@test_snap_protected
$ rbd snap rm test_pool/test_image@test_snap_protected
$ rbd snap ls test_pool/test_image
```

### clone image

```shell
// create a new image with format 2(support clone, default is 1)
$ rbd create test_pool/test_image2 --size 1024 --image-format 2

// map image to device
$ rbd map test_pool/test_image2
/dev/rbd1

$ rbd showmapped
  id pool      image       snap device    
  0  test_pool test_image  -    /dev/rbd0
  1  test_pool test_image2 -    /dev/rbd1

$ mkfs.ext4 /dev/rbd1
$ parted -l | grep /dev/rbd1 -A5
  Disk /dev/rbd1: 1074MB
  Sector size (logical/physical): 512B/512B
  Partition Table: loop
  Number  Start  End     Size    File system  Flags
   1      0.00B  1074MB  1074MB  ext4

$ mkdir -p /mnt/test2
$ mount /dev/rbd1 /mnt/test2
$ df -hT | grep rbd1
  /dev/rbd1      ext4      976M  1.3M  908M   1% /mnt/test2

$ echo 1 > /mnt/test2/hello.txt
// create snapshot
$ rbd snap create test_pool/test_image2@test_snap_for_clone

// protect snapshot
$ rbd snap protect test_pool/test_image2@test_snap_for_clone

// clone image from snapshot to default pool 'rbd'
$ rbd clone test_pool/test_image2@test_snap_for_clone test_image_cloned

// clone image from snapshot to same pool
$ rbd clone test_pool/test_image2@test_snap_for_clone test_pool/test_image_cloned

// list image in default pool
$ rbd list
  test_image_cloned

// list image in test_pool
$ rbd list test_pool | grep test_image_cloned
  test_image_cloned

// list all images which were cloned from a snapshot
$ rbd children test_pool/test_image2@test_snap_for_clone
  rbd/test_image_cloned
  test_pool/test_image_cloned
```

### fill clone with parent data

```
$ rbd flatten test_pool/test_image_cloned
  Image flatten: 100% complete...done.
```
