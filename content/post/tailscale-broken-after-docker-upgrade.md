---
author: Cristian Livadaru
categories:
- tech
- docker
title: "Tailscale Broken After Docker Upgrade"
image:
date: 2025-01-21T18:13:25+01:00
slug: tailscale-broken-after-docker-upgrade
tags:
- docker
- tailscale
draft: true
summary: After updating my linux server, which installed containerd.io 1.7.24,
    tailscale inside docker stopped working.
---

This will be a rather short post and mostly a reminder to myself.
After a routine update of my linux server, which installed containerd.io 1.7.24, tailscale inside docker stopped working.
The logs showed something like this:

```
wgengine.NewUserspaceEngine(tun "tailscale0") error: tstun.New("tailscale0"): operation not permitted
```

A quick search gave me this [issue](https://github.com/tailscale/tailscale/issues/14256#issuecomment-2509791148)
which suggested to move the tun device from a volume to a device.
Instead of having this in my docker-compose.yml:

```yaml
volumes:
  - ./state:/var/lib/tailscale
  - ./config:/config
  - /dev/net/tun:/dev/net/tun
```

I changed it to this:

```yaml
volumes:
  - ./state:/var/lib/tailscale
  - ./config:/config
devices:
  - /dev/net/tun:/dev/net/tun
```
Restarted the stack and voila, it worked.
