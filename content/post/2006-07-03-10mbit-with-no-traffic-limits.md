---
author: Cristian Livadaru
title: "10Mbit with no Traffic limits?"
date: 2006-07-03
url: /2006/07/03/10mbit-with-no-traffic-limits/
slug: 10mbit-with-no-traffic-limits
categories:
  - tech
draft: false
---
#

yes, Blizznet has offered it’s customers as a kind of "thank you" a real flatrate for July and August and this with normal Blizznet speed ( 10Mbit )
The result after the first weekend ( Today is the 3rd as some might have noticed ) is this:

```

ipacsum -s 200607010000
IP accounting summary
Host: foo.bar / Time created: 2006/07/03 13:38:19 CEST
Data from 2006/07/01 00:00:00 CEST to 2006/07/03 13:38:19 CEST
  forwarded incoming GREEN (eth0)                 :             23G
  forwarded incoming RED (eth1)                   :             13G
```

that would be 13G of download and 23G of upload … in only 2.5 days!
