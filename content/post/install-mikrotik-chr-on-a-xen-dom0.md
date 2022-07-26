---
author: Cristian Livadaru
categories:
- sysadmin
date: "2018-10-12T11:15:19Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1520869562399-e772f042f422?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=630505800c3ac5fc0bca1436a432f6f1
slug: install-mikrotik-chr-on-a-xen-dom0
summary: If you want to play around with mikrotik or a need a mikrotik CHR, you can
  install it on XEN and run it without any issues.
tags:
- sysadmin
title: Install Mikrotik CHR on a XEN dom0
---


## Download CHR

Download the mikrotik CHR raw image and unzip it

```
wget 'https://download.mikrotik.com/routeros/6.46.1/chr-6.46.1.img.zip'
unzip chr-6.46.1.img.zip

```

## Create the LVM

Craete a new LVM and copy the data from the image

```
lvcreate -L 1G -n chr vg0
dd if=chr-6.46.1.img of=/dev/vg0/chr.lcx.at-disk

```

## Create XEN configuration

### Generate new UUID

If you intend to buy a license for this CHR you need to make sure that yhe software-id does not change with every reboot, unforutnately the default setting would results in a new software id after every reboot, this would break the CHR license and you are stuck with 1Mbit. Trying to purchase a license will give you this error:

`status: ERROR: This System ID is not valid for license`

To create a unique uuid, run `uuidgen` and use this in the xen configuration below, thanks to the [Mikrotik forum for this hint](https://forum.mikrotik.com/viewtopic.php?t=110173#p548654).

```
$ uuidgen
27F7EDA4-78DD-4706-89D8-0601964BD6BC
```

Craete a file `/etc/xen/chr.cfg` with the xen config

```
builder = 'hvm'
name = 'chr'
memory = 512
maxmem = 512

# this is needed so that the system id does not change
uuid = "27F7EDA4-78DD-4706-89D8-0601964BD6BC"

vcpus = 1
pae = 1
acpi = 1
viridian = 0
apic = 1
device_model = '/bin/true'
boot = 'cd'
sdl = 0
usb = 1
usbdevice = 'tablet'
vnc = 1
vnclisten = '0.0.0.0'
serial = 'pty'
vif = [ 'type=ioemu, bridge=xenbr0, ip=127.0.0.1, mac=some:mac:address:here']
disk = [ 'phy:/dev/vg0/chr,hda,w']
on_poweroff = 'preserve'
on_reboot = 'restart'
on_crash = 'restart'

```

replace the ip and mac address, you can use this [Random MAC Address Generator](https://justyn.io/projects/random-mac-generator/) to generate a new random MAC Address for the vm.

## Start it

now you can start the mikrotik CHR and connect to it via VNC

```
xl create /etc/xen/chr.cfg

```

## Credits

XEN script is based on [this post on the mikrotik forum](https://forum.mikrotik.com/viewtopic.php?t=112162#p569679) from maznu

