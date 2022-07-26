---
author: Cristian Livadaru
date: "2021-06-23T13:27:25Z"
description: ""
draft: true
slug: create-your-own-telegram-enabled-watchdog
summary: Recently I noticed my node-red rapsberry crashed but this was two days after
  it crashed. There is nothing critical on it, just gathering some weather sensor
  data and pushing it to a Grafana, but it would still be nice to be informed that
  it crashed.
title: Create your own Telegram enabled Watchdog
---


## Why not usual monitoring?

You could of course go with something like nagios, zabbix (please don't!) or sensu. But given that our sensu setup is completely in ansible (Thanks to the awesome work Jan) it would not be so great to add my home devices to the company monitoring, nobody want's to know when my weather station crashed. So I decided to go for something simple and also play around with some of the new shiny tools.

I decided to go for a mix between [node-red](https://nodered.org/), [n8n](https://n8n.io/) and [nocodb](https://www.nocodb.com/). Yes it might seem a bit exaggerated but I wanted to play around with all of those tools and see what I could come up with. I won't cover the setup of all those tools, there are several instruction on how to get everything up and running

## Timeouts in node-red

Node Red has this great Timeout node, which starts a countdown as soon as data is received, if it doesn't receive any data for a while the node will send a message.

