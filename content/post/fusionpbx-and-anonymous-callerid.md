---
author: Cristian Livadaru
categories:
- voip
date: "2019-02-12T11:27:13Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1525542644600-bce74baf408d?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ
slug: fusionpbx-and-anonymous-callerid
summary: Some carriers might block calls if the call has no caller id in the sip FROM.
  I stumbled upon such an issue while forwarding inbound calls from FusionPBX to a
  cell phone number. The calls were rejected if they reached fusionpbx with anonymous
  as the caller id.
tags:
- voip
title: FusionPBX and anonymous callerID
---


## When does this happen?

In my setup, I receive calls to fusionpbx with cleaned up callerID if it was hidden by the caller. My Gateway still sees the call but correctly strips it away before passing it on to fusionPBX. All works fine if that anonymous call will be handled by fusionpbx without forwarding it back to PSTN again. If however the call will be forwarded to PSTN, some carriers might block the call.

## Why is this happening?

Well, apparently someone thought it would be a good idea to make interconnection fees based on the caller id! What this means, if I call an Austrian number that resides with let's say Telekom Austria with my Austrian office callerID the interconnection fee between my carrier and Telekom Austria differs from the same call if I would use a US CallerID for example.
So the same person is calling from the same server via the same connection but interconnection fees differ because of the different caller id. I wonder in which f** universe this makes any sense.

![mind-blown](__GHOST_URL__/content/images/2019/02/mind-blown.gif)

## How to fix it? 

In fusionPBX edit the `default_caller_id` dialplan and in case the caller_id_number is `anonymous` then update the `outbound_caller_id_name` and `outbound_caller_id_number` to your customers DID and add the privacy headers to send the call with a hidden callerID.
This will result in you carrier accepting the call and sending it out with privacy headers set, so the receiver of the call will of course only see that it's anonymous call but everyone is happy. 

![FusionPBX Anonymous callerID](__GHOST_URL__/content/images/2019/02/2019-02-12_13-09-58.png)

