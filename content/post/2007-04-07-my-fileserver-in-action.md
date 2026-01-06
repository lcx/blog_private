---
author: Cristian Livadaru
title: "My fileserver in action"
date: 2007-04-07
url: /2007/04/07/my-fileserver-in-action/
slug: my-fileserver-in-action
categories:
  - tech
draft: false
---
#

Well, after I managed to fill 600Gigs it was time to get a new hard disk. I do still have some IDE Ports on that boad free, but why not get a SATA controller and a brand new SATA disk instead? Faster and it will also work if I switch the mainboard.

Well, there was only one problem, I still had my two big discs in a RAID 0 array which can’t be expanded by a third disk so it was time to switch to LVM. Lucky me that I had 4 SATA disks for the server I am working on where I can move my data to free the disks for the LVM. It took awhile to move 600gigs but now everything is done and my fileserver is back online with a nice and big LVM that could be expanded …. if I had more power connectors for the hard disks and space in the case for a new disk, the harddisk in the photo that is outside of the case is really connected and running


```

LV        VG      Attr   LSize    Origin Snap%  Move Copy%
sharelv   sharevg -wi-ao  931.52G
```
