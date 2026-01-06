---
author: Cristian Livadaru
title: "nagios with sms notification"
date: 2006-04-27
url: /2006/04/27/nagios-with-sms-notification/
slug: nagios-with-sms-notification
categories:
  - tech
draft: false
---
#

so finaly I finished seting up nagios on my server to monitor themselves and in case of a problem send me an SMS.
I found a plugin to send the sms on the [nagios exchange][1] site but that didn't quite work out of the box.
First problem is that the URL creation will never work, the URL for the message is created before the session id is assigned to the variable, this can't work! The second problem is that the message is sent "as is" for example "Server xy is down" this won't work either! The text has to be url\_encoded ( in php, or uri\_encode in perl ) so I created a patch which you can [download here][2].
Then the description of the usage on the site is not correct 

 [1]: http://www.nagiosexchange.org/Notifications.35.0.html?&tx_netnagext_pi1[p_view]=371&tx_netnagext_pi1[page]=10:10 "notify_sms"
 [2]: http://livadaru.net/cristian/downloads/notify_sms-1.1.patch "notify_sms-1.1 Patch"

> define command{
> command\_name service\_notify\_with\_sms
> command\_line /usr/lib/nagios/plugins/notify\_sms -a 1012345 -u myusername\_for\_gw -p mypassword\_for\_gw -m '$NOTIFICATIONTYPE$: $HOSTNAME$ is $SERVICESTATE$ ($SERVICEOUTPUT$)' -t $CONTACTPAGER$
> }

It should be $OUTPUT$ and not $SERVICEOUTPUT$ but this was the rather minor problem.
