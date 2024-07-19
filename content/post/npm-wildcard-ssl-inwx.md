---
author: Cristian Livadaru
categories:
- tech
date: "2024-07-19T12:39:11Z"
title: "Generating let's encrypt wildcard SSL certificates with INWX and DNS challenge"
image: /images/2024/07/broken_city_timisoara.jpg
slug: npm-wildcard-ssl-inwx
summary: "Using INWX as a DNS provider for the DNS challenge with nginx-proxy-manager
  and Let's Encrypt wildcard SSL certificates is easy, but what the hell is that shared secret?"
draft: false
tags:
- ssl
- letsencrypt
- nginx-proxy-manager
---

Now that I've started with the wildcard SSL certificates, I wanted to try it with another provider, INWX.
I honestly don't want to keep running my own nameservers, even if it's easy with ISPconfig, but with current
new legislations regarding NIS2, I don't want to take the risk of running my own nameservers anymore.

INWX has a nice API that you can use to create the TXT records for the DNS challenge, so let's see how we can use
this with nginx-proxy-manager and INWX.

## Requirements from INWX
Well, there's not much to configure here. You need your username and password, however, if you have 2FA
enabled, which I highly recommend, then I hope you saved the "Shared secret" somewhere.
I didn't, so to fix this, I had to disable 2FA, enable it again and save the shared secret this time.
IF you are asking what the shared secret is, it might not be so obvious, but it's displayed when you enable 2FA
under the QR code. Take that code, add it to your password vault and you are good to go.

## Creating a new wildcard certificate with NPM
There's nothing to it now. Just select DNS Challenge, select INWX as the provider and add your username, password and shared secret.

```
dns_inwx_url = https://api.domrobot.com/xmlrpc/
dns_inwx_username = your_username
dns_inwx_password = your_password
dns_inwx_shared_secret = your_shared_secret optional
```

Figuring out what that shared secret is took me the most time.
