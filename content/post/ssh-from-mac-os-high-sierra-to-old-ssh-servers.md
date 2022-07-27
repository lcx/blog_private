---
author: Cristian Livadaru
categories:
- tech
date: "2018-01-08T08:00:00Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1484043937869-a468066a4fbd?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=ca50ed13a1c9c824c3bcfe06881b79d3
slug: ssh-from-mac-os-high-sierra-to-old-ssh-servers
summary: Change SSH client settings to enable SSH logins to older SSH servers or Mikrotik
  routers
tags:
- linux
- mac os
- ssh
title: SSH from Mac OS High Sierra to old SSH Servers
---


If you are trying to connect to older ssh servers or Mikrotik routers from Mac OS High Sierra you might encounter some of these error messages:

* `no matching host key type found. Their offer: ssh-dss`
* `no matching cipher found. Their offer: aes192-cbc,aes128-cbc,aes256-cbc,blowfish-cbc,3des-cbc`
* `DH GEX group out of range`

If you can't upgrade the router firmware (you really should do that first) then you can edit your client ssh config `vim .ssh/config` and add these lines:

```
Host foo.example.com
    HostKeyAlgorithms ssh-dss
    KexAlgorithms diffie-hellman-group1-sha1
    Ciphers +aes192-cbc
```

