---
author: Cristian Livadaru
title: "raid+lvm ... can get tricky if you don look exactly"
date: 2006-07-19
url: /2006/07/19/raidlvm-can-get-tricky-if-you-don-look-exactly/
slug: raidlvm-can-get-tricky-if-you-don-look-exactly
categories:
  - tech
draft: false
---
#

I should think twice before doing stuff with lvm on a raid ! I am setting up a new server, rebooted it with a rescue system so I could create the raid 1, this was quite simple mdadm –create …. and raid was finished, then the lvm over it, pvcreate, vgcreate, lvcreate and ready to go … but alas I had to reboot the rescue system ( shit happens ) after the reboot ( since it was a rescue system which is read only ) the raid didn't start, but I could start lvm  which of-course complained that things are double ( on sda and sdb, because of the raid) I actually ignored that and started installing xen, after a short time I noticed what big shit I did.  so … I stoped lvm again, starte raid ( mdadm –assemble /dev/md0 /dev/sda2 /dev/sdb2 ) and the raid is reconstructing. I have NO clue what it will look like after it's finished, no idea where the lvm acutaly write to ( sda or sdb? ) and if after the rebuild of the raid the data will still be there … maybee I should just start from scratch.

the result was … all I did was gone, so I had to restart with the xen installation
