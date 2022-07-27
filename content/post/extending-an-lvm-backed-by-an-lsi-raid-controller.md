---
author: Cristian Livadaru
categories:
- tech
date: "2018-01-07T11:47:51Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1505424297051-c3ad50b055ae?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=210f68f876007092a8afec505ff31dea
slug: extending-an-lvm-backed-by-an-lsi-raid-controller
summary: Adding new disks to a LSI controller, creating a new VD and extending an
  existing LVM volume group
tags:
- linux
- sysadmin
- raid
title: Extending an LVM backed by an LSI RAID controller
---


Since I always keep forgetting, here a reminder for myself how to add a new VD and extend the LVM. I usually keep forgetting the LSI commands.
In this case, I had to extend an LVM to get some extra space, this means adding new disks, creating a new VD on the LSI controller and then extending the LVM volume group by this new VD.

After adding the new disk, check drive information to get the enclosure and slot.

```
storcli /c0 /eall /sall show
```

You should see the new disks in status "Ugood", so you need to create a new VD from the new disks.
In my case disk from slot 12 and 13 where the new disks so I created a new RAID1

```
storcli /c0 add vd type=r1 drives=8:12-13
```

After this step, you need to start the init of the new vd.
First look at which vd is your new one:

```
storcli /c0 /vall show
```

the last one should be the new one and it will be the one with consistant: no

```
Virtual Drives :
==============

---------------------------------------------------------------
DG/VD TYPE  State Access Consist Cache Cac sCC     Size Name
---------------------------------------------------------------
0/0   RAID1 Optl  RW     Yes     RWTD  -   ON  1.818 TB System
1/1   RAID6 Optl  RW     Yes     RWTD  -   ON  7.275 TB Data
2/2   RAID5 Optl  RW     Yes     RWTD  -   ON  5.457 TB Data2
3/3   RAID1 Optl  RW     Yes     RWTD  -   ON  7.276 TB
4/4   RAID1 Optl  RW     No      RWTD  -   ON  9.094 TB
---------------------------------------------------------------
```

Now Initialize the VD

```
storcli /c0 /vx start init full
```

/vx needs to be replaced by the virtual drive you created (in my case that would be /v4)

and check progress with
```
storcli /c0 /vx show init
```

Now you can start partitioning the drive and add it to the lvm.

A big warning here! **Don't do this before initializing the disks!** If for some reason you created the partition **before** the init - yes you can do that - then you end up with an inconsistent array, you will fiddle around to make the array consistent and at some point remember that you forgot the init, you trigger the init which will remove partition and your LVM will look like this:

```
root@backup:~# pvs
  /dev/sdd: read failed after 0 of 4096 at 0: Input/output error
  /dev/sdd: read failed after 0 of 4096 at 8001020690432: Input/output error
  /dev/sdd: read failed after 0 of 4096 at 8001020747776: Input/output error
  /dev/sdd: read failed after 0 of 4096 at 4096: Input/output error
  /dev/sdd1: read failed after 0 of 512 at 8001019576320: Input/output error
  /dev/sdd1: read failed after 0 of 512 at 8001019678720: Input/output error
  /dev/sdd1: read failed after 0 of 512 at 0: Input/output error
  /dev/sdd1: read failed after 0 of 512 at 4096: Input/output error
  /dev/sdd1: read failed after 0 of 2048 at 0: Input/output error
  Couldn't find device with uuid GLTroE-rzfi-sx58-3ff1-ZDcM-IOYK-WXTcYW.
  PV             VG   Fmt  Attr PSize PFree
  /dev/sda4      vg0  lvm2 a--  1.82t 1.51t
  /dev/sdb1      vg0  lvm2 a--  7.28t    0
  /dev/sdc1      vg0  lvm2 a--  5.46t    0
  unknown device vg0  lvm2 a-m  7.28t 7.28t
```

So after the init was triggered go ahead and add the VD to the LVM

```
pvcreate /dev/sdd1
```

```
vgextend vg0 /dev/sdd1
```

