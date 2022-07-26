---
author: Cristian Livadaru
categories:
- rant
date: "2018-09-06T16:19:25Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1533413257680-5aae79573564?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=cf80a3681e74f6ac7d9b94bfe1bf0e87
slug: transferring-domains-away-from-world4you
summary: Domains transfers normally cause no downtime and no issues but if some registrar
  want's to play rough it can definitely cause some headache.
tags:
- rant
title: Transferring domains away from world4you
---


I recently had to transfer several domains away from an Austrian hoster called "world4you". Nothing special about a domain transfer, you enter the auth code with the new registrar, wait for a little and it's done, usually with zero downtime.
Well here is where world4you differs a little bit from other registrars, at least with .at Domains where world4you is [registrar](https://nic.at/registrar/61) and does not buy from other wholesale vendors.
So here are the issues I stumbled upon: 

* there is no way to change TTL
* your DNS records will instantly be dropped once you trigger the domain transfer. 

This is a very bad way of doing things. Kind of like an angry little kid who takes all his toys away just because you don't want to do what they tell you to.

Since you can't update the TTL the domain remains with the default TTL and since w4y decides to instantly drop the record from their nameserver you are royally screwed!
Provider Nameservers will still see the w4y nameservers as authoritative but get no reply since the records where dropped. Thanks a lot!

This begs the question: Why do you instantly drop the records if I paid for a full year for the domain?

Ok, now how can you fix it? 

Unfortunately, I have no .at domain to transfer for now and this issue does not occur with other TLD but one way you could probably go around this issue would be to first change the nameservers to point to your own nameserver. Wait for a day and after that only trigger the domains transfer.

