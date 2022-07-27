---
author: Cristian Livadaru
categories:
- security
date: "2021-11-26T10:10:30Z"
description: ""
draft: false
image: /images/2021/11/antoine-giret-7_TSzqJms4w-unsplash.jpeg
slug: flooding-phishing-with-curl
tags:
- security
- phishing
title: Flooding phishing forms with bash and curl
---


In 2018 I wrote a quick post on [how to flood phishing pages](__GHOST_URL__/how-to-deal-with-phishing-sites/) with a python script. Unfortunately that doesn't work with python3 anymore and also doesn't handle POST request, me not really being a python dev decided to use bash with two packages instead of coding something in ruby.

## Install packages

```bash
apt install pwgen gpw
```

That's it for the packages, now you have something to generate usernames and passwords.

## Gather the fields

Looking at the page sources shows two fields being used, a field email and password.

{{< figure src="/images/2021/11/CleanShot-2021-11-26-at-11.37.21.png" >}}

Now what happens once the user clicks on submit?

{{< figure src="/images/2021/11/CleanShot-2021-11-26-at-11.38.43.png" >}}

If the user has tried 3 times, a redirect to the real microsoft page will be triggered. The first requests however are passed on to a next.php via POST Request.

## The Script

```bash
for ii in {1..500}
do
  EMAIL=`gpw 1`@`gpw 1`.com
  PW=`pwgen -s 10`
  curl -X POST -F "email=$EMAIL" -F "password=$PW" https://some.phishing.url.com/next.php; echo "$ii posted $EMAIL/$PW"; done
```

nothing fancy but should be enough to fill up the phishing site with a lot of crap data.

Photo by [Antoine GIRET](https://unsplash.com/@antoinegiret?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/trash?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

