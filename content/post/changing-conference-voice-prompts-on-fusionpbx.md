---
author: Cristian Livadaru
categories:
- voip
- fusionpbx
date: "2017-12-12T15:50:44Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1431540015161-0bf868a2d407?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=a6aee11e4369e1d32511ff97bf77b4f4
slug: changing-conference-voice-prompts-on-fusionpbx
summary: Offering VoIP solutions to endusers requires the VoIP system to speak their
  language. Here's how to change the language for the conference system on fusionpx
tags:
- voip
- fusionpbx
title: Changing conference voice prompts on FusionPBX
---


Even if you set your fusionpbx to some other language, you might be wondering why the conference still uses English for prompts. 
The reason for this is that the conference uses settings from the conference profile which seems to default to English but it's quite easy to fix. 
Keep in mind, this setting applies to all domains! 

Go to Apps -> Conference Profiles and edit the profile you want. 
If you want different settings (different Domains for example), you could copy the profile and create separate profiles with different languages.

![2017-12-12_17-37-18](__GHOST_URL__/content/images/2017/12/2017-12-12_17-37-18.png)

Click + to add a new value

![2017-12-12_17-38-10](__GHOST_URL__/content/images/2017/12/2017-12-12_17-38-10.png)

and add a parameter sound_prefix with the path to your language files

![2017-12-12_17-38-19](__GHOST_URL__/content/images/2017/12/2017-12-12_17-38-19.png)

save and you're done!

