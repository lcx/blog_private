---
author: Cristian Livadaru
title: "bye bye LVM, hello raid0"
date: 2006-09-13
url: /2006/09/13/bye-bye-lvm-hello-raid0/
slug: bye-bye-lvm-hello-raid0
categories:
  - tech
draft: false
---
#

Du to the extreme performance that LVM gave me I decided to change my 2 big disks in a raid0 instead. It's strange, I have a LVM in the same computer with no problems and a LVM on my production server, also no problems. Only the LVM with the two 300GB Disks caused problems. just look at this performance!

```

dd if=/dev/zero of=dd.txt count=500 bs=4096
500 0 records in
500 0 records out
2048000 bytes transferred
in 10.020213 seconds (204387 bytes/sec)
```

this is 199 kb/s ! on a local disk! that performance increased to 3.6mb/s after booting with Kernel 2.4 well and here is is the raid0 performance

```
dd if=/dev/zero of=dd2.txt count=500 bs=4096
500 0 records in
500 0 records out
2048000 bytes transferred
in 0.016208 seconds (126356878 bytes/sec)
```

120 mb/s just a smaaaaal difference. ok then I booted again with kernel 2.6 and tested again, and guess what? again something about 200k/s ! hmm… somehow it came to my mind to mount it manually with no options from fstab, and now I got a performance of 180mb/s ! What was the problem? here are my mount parameters: sync,user,rw,auto,errors=remount-ro after removing the sync everything was fine. Why didn't this come to my mind earlier? before I moved al my date on all disks I could find. arggggg….
