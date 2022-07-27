---
author: Cristian Livadaru
categories:
- tech
date: "2017-12-10T13:50:20Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1504639725590-34d0984388bd?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=a2c64b46cd380a3cb8fe6acda35d735d
slug: changing-disks-of-a-linux-mdadm-raid
summary: If you change all disks at once there will be issues booting the system and
  mounting the correct disks, here's how I solved this issue.
tags:
- linux
- sysadmin
- raid
title: Changing disks of a Linux mdadm RAID
---


Having a failing software RAID isn't a big issue, if monitoring is working (which wasn't) and alerts are working (which where not) and the second disk of the raid is still working without issue, but I wanted to use this occasion to replace the disks against larger disks which also isn't that hard but there are some things to be aware of to not screw it up, so here we go.
Be aware that you can't rely on this as a copy and paste manual, think before you do anything, especially that I wrote this a couple of days after replacing the disks and memory might have faded on this already.

If you ever see something like this from smartcl, then you better hurry up with those disks and hope you have a good backup.

```
Drive failure expected in less than 24 hours. SAVE ALL DATA.
```

## Preparation
Shut of the server and insert new disks.
In case your RAID is already degraded, make sure to pick the right disk from which you copy the data, on a raid1 you can access the data on the running disk without assembling the raid.
Chances are that the broken disk won't be accessible but you never know and if you mount the wrong disk you might copy old data.

## Rescue System
First, you need to boot from a rescue system, I used [Grml](http://grml.org/) for this which was a great help, put it on a USB stick boot the system and you are good to go.

## Copy the old data
After booting up, mdadm and lvm are good to go, just that all lvm are inactive and have to be activated in order to be able to access it.

```bash
lvchange -a y /dev/vg0/...
```

Now you can copy your old data, my tool of choice is rsync

```bash
rsync -avP --numeric-ids /old-mount/ /new-mount/
```

## Install GRUB on the new disks
From the rescue system, run grub-install on the new disks.

```bash
grub-install /dev/sda
grub-install /dev/sdb
```


## Chroot into the old system

To continue you need to chroot into the old system but before that bind mount some directories from the rescue system into the new system,

```bash
mount --bind /dev /new-mount/dev/
mount --bind /proc /new-mount/proc/
mount -t sysfs sys /new-mount/sys/
```

and now chroot

```bash
chroot /new-mount/
```

## Create a new mdadm.conf

In order for the software raid to work after rebooting, you need update /etc/mdadm.conf

```bash
mdadm --examine --scan >> /etc/mdadm.conf
```

Edit the file and remove the old disks from mdadm.conf or if you still need the disks after reboot, change the lines to not conflict with the new disks since you can't have two md0 for example.

## Update grub
First run update-initramfs to put all changes in initram.

Now run update-grub to fix grub otherwise it will try to boot from the old disks. Remember that you are still in chroot.


## Fix fstab
Check your fstab and fix disk id's to boot from the correct disks.

## Reboot

Think that was everything needed to get the system up and running. Thanks to grml.org for the great rescue system.

