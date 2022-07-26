---
author: Cristian Livadaru
categories:
- fusionpbx
- freeswitch
date: "2018-06-08T09:59:04Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1505682128212-a6a59a6abbae?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=6adb0c5752f48602ac466fd61eaac052
slug: freeswitch-audio-after-pickedup
summary: Want to play and audio to the called number after the call was picked up?
tags:
- fusionpbx
- freeswitch
title: 'Freeswitch/Fusionpbx: Play audio after call was picked up'
---


If you want to play an Audio to the called person once the call was picked it, this is quite simple to accomplish with freeswitch / fusionpbx. 
It's not the most elegant way as I haven't figured out yet how to add an extra confirm prompt for call groups in fusionpbx but for now this does the trick. 
In the Dialplan, before transfering the call, add an `execute_on_answer` with `nolocal`

```
action export: nolocal:execute_on_answer=playback /var/lib/freeswitch/recordings/<DOMAIN>/<WAV FILE>
```

![2018-06-08_13-54-15-1](__GHOST_URL__/content/images/2018/06/2018-06-08_13-54-15-1.png)

There is one issue with this, the audio starts playing much to fast, so add some blank audio at the beginning.

