---
author: Cristian Livadaru
title: "DoS attack?"
date: 2006-10-12
url: /2006/10/12/dos-attack/
slug: dos-attack
categories:
  - tech
draft: false
---
#

Yesterday I had to reboot my server after it was unreachable. It all started with nagios sending me some sms, to many process, http doesn't respond, https doesn't respond …
As I finally managed to try to login it was already to lade, the server wasn't responding anymore. After a reboot everything was fine again, but not for long. Again from the same many connections to apache where made so I added the ip to the firewall blacklist and now it's silent again.
But this is not a final solution, I made some new adjustments to Apache, now only limited connections/IP are allowed, I tried first 5 but although I wasn't doing much I got the "Service temporary unavailable" message so I increased it to 10, further have I set the MaxClients count from apache from 150, to 100 and I am thinking of reducing it further, I will have to do a stress test some day. The next step will be bandwidth limitation, some domains are already limited by mod_bandwidth but I would like to solve it different and not with a apache module. Well some information really comes when you need it, a friend of mine pointed me to TC (traffic control) so I will take a look at that, when I have time.
