---
author: Cristian Livadaru
title: "RTFM! posibly before installing something"
date: 2006-04-25
url: /2006/04/25/rtfm-posibly-before-installing-something/
slug: rtfm-posibly-before-installing-something
categories:
  - tech
  - rant
draft: false
---
#

I should know it better, especially that this isn't the first time it happens. I installed once again after a long time nagios on my server so I have something that keeps an eye on the server. Anyway … I installed nagios-mysql ( as I did the last time ) but it looks like the database has to be created before installing, or … who knows, I still didn't RTFM. well the result was that the 5 min. nagios was running I dumped about 2 gigs of syslog messages that where saved in the syslog, message, users AND the nagios.log … I had over 8 Gigs of logs, good performance test for syslog-ng by the way. Anyway now I finally cleaned up everything, as .gz the file isn't that big at all only 8.5 MB, OK now that logrotate is finished I should get back to my server.
