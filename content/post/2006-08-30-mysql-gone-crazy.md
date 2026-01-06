---
author: Cristian Livadaru
title: "Mysql gone crazy"
date: 2006-08-30
url: /2006/08/30/mysql-gone-crazy/
slug: mysql-gone-crazy
categories:
  - tech
draft: false
---
#

Good that I always switch of my mobile when I go to sleep. Why? Imagine waking up, switching your mobile on and then the ringing begins, you get one sms after the other … a total of 45 messages. Oh no … not what you might think, it was nagios that was telling me that something is wrong with the server. For some reason (couldn’t find out why) mysql had a cpu usage of 88-99% and my server had a load average of 11 !
There was no way mysql wanted to shut down so the only solution kill -9. Everything is running again but I hate it when something happens and I don’t know why. Now I can just hope it won’t happen again.
