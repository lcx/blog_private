---
author: Cristian Livadaru
categories:
- tech
tags:
- xen
image: /images/2023/04/xen-grant-table.jpg
title: "💥Solving max_grant_frames under XEN"
slug: xen-max-grant-frames
date: 2023-04-18T11:48:42+02:00
summary: Being hit with this problem a second time, I noticed that the initial 
  fix was not enough. There are pieces of informations scattered around several
  mailinglists, forum posts, blogs and also a very detailed technical explenation on
  what is happening under the hood, but I couldn't find a post describing the solution.
  So here goes my take on how to solve this.
draft: false
---
## The issue
Looking at a XEN `domU` `dmesg` you might find log entries like this: 

```
xen:grant_table: xen/grant-table: max_grant_frames reached cur=32 extra=1 limit=32 gnttab_free_count=1 req_entries=32
```
If you have these log entries it doesn't mean that your VM will freeze but it sure isn't a good sign and if your VM keeps
on having load, then it will eventually freeze. 
The freeze itself looks weird, if you start `top` or `htop` there is nothing off, but the load still increases over 30
and keeps on going. Eventually, you won't even manage to execute a `touch test.txt`, it will just freeze and all you can
do is stop the VM and restart it.

### How to check before it happens
You can run following command to see if any of your VM is reaching the max value

```bash
xen-diag gnttab_query_size 61
```

where 61 is the VM id

```
domid=61: nr_frames=24, max_nr_frames=32
```

here you can see that it uses 24 out of the maximum applied 32. 

## Fixing the issue. 
As mentioned in this KB from SuSE Linux [I/O to LUNs hang / stall under high load when using xen-blkfront | Support | SUSE](https://www.suse.com/support/kb/doc/?id=000018854) it recommends 

> Increase the default "gnttab_max_frames" of "32" to a higher value by starting the Hypervisor (Dom0) with the kernel parameter "gnttab_max_frames=xxx".

But for me this was already the case, so what's going on? 
Well, as mentioned above you can check this value on a `domU` which means you can also set this setting for every `domU`!
Further down in the KB article from SuSE, it's also mentioned: 

> To change the value for guests add "max_grant_frames=xx" to their configuration file or add the entry to "/etc/xen/xl.conf" in order to set the default for guests without having "max_grant_frames" in their configuration.

So, let's start fixing this issue with the `dom0` and then continue with the `domU` in question.
My described fix here is for Debian Linux!

### dom0 settings
Edit `/etc/default/grub` and add a `gnttab_max_frames` setting, 256 was the recommended setting in the KB but it also contains some hints on how to calculate it. 
I will just stick with 256 for now. 

```
GRUB_CMDLINE_XEN_DEFAULT="dom0_mem=2048Mlmax:2048M dom0_max_vcpus=6 dom0_vcpus_pin gnttab_max_frames=256"
```

Generate your grub configuration and reboot. This will fix the issue for the `dom0` but as mentioned not for any VM running.

### domU settings
This is as simple as editing the configuration for the VM and defining `max_grant_frames='256'`
So for example having a VM configuration `/etc/xen/database.cfg`

```
vcpus       = '8'
memory      = '16384'
cpus="all,^0-3"
max_grant_frames='256'
```

stop and start the vm (reboot probably won't do it) and check with `xen-diag gnttab_query_size` to confirm.
Also after starting check `dmesg` to see if any further log entries are created.


## Technical details
If you're curious on what is happening under the hood, there is a details post from Damien, an XCP-NG developer explaining the
[Grant Table in Xen](https://xcp-ng.org/blog/2022/07/27/grant-table-in-xen/)


Photo by [Gareth Harrison](https://unsplash.com/@gareth_harrison?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/crash?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
