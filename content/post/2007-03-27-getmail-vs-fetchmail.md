---
author: Cristian Livadaru
title: "getmail vs fetchmail"
date: 2007-03-27
url: /2007/03/27/getmail-vs-fetchmail/
slug: getmail-vs-fetchmail
categories:
  - tech
draft: false
---
#

I recently got quite fed up of fetchmail. The problem is that there are mails on an account from invalid sender domains (like foo.bar for example) since my Postfix rejects such mail because it can only be spam fetchmail didn’t manage to delete them. So it looped leaving the junk mails on the pop account and flooding my logfiles.
The solution was getmail. Since I use postfix amavis cyrus there was no example config that fits my needs so I did some experiments but finally a mail from Elimar Riesebieter on the Mailinglist solved my problem.

So I want to share my [mini howto][1] of how I configured getmail to run with amavis. I also explain how to use it with avira (former hbedv) Antivir.

 [1]: https://web.archive.org/web/20090508071617/http://livadaru.net:80/cristian/wiki/index.php/Getmail
