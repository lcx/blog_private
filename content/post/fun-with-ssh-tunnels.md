---
author: Cristian Livadaru
date: "2017-12-19T11:28:01Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1494699483104-af5b3b0209d4?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=da0a26c60be0be2bf57f78f935afcd49
slug: fun-with-ssh-tunnels
summary: How to connect to a server behind a firewall through a SSH tunnel
title: Fun with ssh tunnels
---


## Slow ISP

I have two ISP lines, one giving me a static IP and which I use for my VoIP phones due to better quality and lower latency with the drawback that I only have 8Mbit and the other one for better speed but higher latency and not so reliable. 
As it seems today seems to be a bad day as the line was slow as a snail stuck on chewing gum and I really needed to do something on that server. 

## SSH Tunnels to the rescue

Now, to overcome this issue and connect from my fast line to the firewalled server I used some SSH tunnel magic :) 
From the firewalled server I connect to a second server, reachable from the outside and create a reverse tunnel: 

`ssh user@example.com -R 2424:localhost:22`

This connects you to example.com, opening port 2424 on example.com which is a tunnel back to the firewalled server (hence the localhost:22 part)

The issue is that the tunnel is only listening on localhost on example.com so this means that if you need a SSH Key you can't ssh from your local machine to example.com port 2424 ... so we need one more tunnel :) 

## Even more tunnels 

Now from your local machine create a new tunnel 

`ssh user@example.com -L 2426:localhost:2424`

This connects you to example.com opening a port 2426 on your **local machine** which is a tunnel to example.com port 2424.

Now on your local machine open up a new terminal, ssh to user@localhost -p 2426 and you will go through both tunnels and pop out on the firewalled server through the fast ISP Line and through SSH secured tunnels.

