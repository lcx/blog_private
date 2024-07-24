---
author: Cristian Livadaru
categories:
- tech
date: "2024-07-24T18:39:11Z"
title: "Postfix complains about Cannot start TLS: handshake failure"
image: /images/2024/07/broken_city_timisoara.jpg
slug: postfix-tls-error
summary: "Ok, this was a huge waste of time going down this rabbit hole.
    Postfix complains about handshake failure when trying to send emails over TLS.
    Non TLS works fine, receiving mails via TLS works fine, what gives?"
draft: false
tags:
- ssl
- sysadmin
- networking
---

It all started with a returned email that contained:

```
530 5.7.0 STARTTLS is mandatory (in reply to RCPT TO command)
```

ok, that was unexpected, everything has been working fine a few hours later.
I did indeed move this mailserver and added new SSL Certificates, but the
certificates are needed only for receiving emails, not sending them.

The logs contained these informations:

```
SSL_connect error to mail.protection.outlook.com[52.101.73.30]:25: Connection reset by peer
Cannot start TLS: handshake failure
```

Things I have checked:

* postfix configuration is completly the same as before
* certificates of receiving mail server are ok and valid (I should have tried
to check them from withing the container)
* Emails via non-TLS work fine, if the server is configured to accept non-TLS.

This is probably the time when I started going down the rabbit hole of first
checking if there where any other related changes in the container project,
any open issues or closed issues that relate to TLS. Of course there was nothing.

Time to check some cipher settings then.
I first stumbled over this interesting post [Postfix failing with “no shared cipher”](https://michael-prokop.at/blog/2023/09/25/postfix-failing-with-no-shared-cipher/).
While it was definitely an interesting read, it wasn't my issue. In this case the issue was
with receiving mails, my problem was the other way around.

Stumbled over another interesting read [Postfix: TLS-Konfiguration mit ECDSA- / RSA-Zertifikaten](https://www.kuketz-blog.de/postfix-tls-konfiguration-mit-ecdsa-rsa-zertifikaten/),
this one is in german. But again it made no sense to start changing the cipher settings,
this all worked and works from the old server with the same configuration.

## Back to the basics
Ok, let's start from the beginning. Let's go into the container and check the connection.

```bash
openssl s_client -connect mail.protection.outlook.com:25 -starttls smtp
```

aaaand we've got nothing. No reponse. Same thing outside of the container works.
This makes no sense. The IP can't be blocked, it's the same both from within as from
outside the container.
But let's make sure ... let's use telnet.
While there is a nice way to use telnet using the namespace of the docker container,
I neve remember the syntax.
If you are interested in this topic, go ahead and watch this video from Tailscale:
[A deep dive into using Tailscale with Docker](https://youtu.be/tqvvZhGrciQ?feature=shared&t=1157)

```bash
docker inspect -f '{{.State.Pid}}' rspamd-postfix
12345
```
this gives us the PID of the container. Now we can use nsenter to enter the network namespace of the container.

```bash
nsenter -t 12345 -n telnet mail.protection.outlook.com 25
```

but again, since I always forget this syntax, time to install telnet in the container.

```bash
apt update && apt install telnet
```

aaaand it's stuck at the `apt update`.
And this was the moment I slaped myself in the face.

![MTU Fail](/images/2024/07/mtu-fail.jpg)

The reason for this is some special network setup in the Datacenter, won't go too much
into details here, but the MTU needs to be set to 1400, not the default 1500.
While the server itself has the correct MTU, the container doesn't.
The issue doesn't really show itself until you are dealing with https, tls etc.
Only then you will have connection issues, non encrypted connections work fine which
always sends me down the wrong path.

This little snippet in the docker-compose file fixes the issue:
```yaml
networks:
  default:
    driver: bridge
    driver_opts:
      com.docker.network.driver.mtu: 1400
```

if it only would have been the first time I forgot this.
