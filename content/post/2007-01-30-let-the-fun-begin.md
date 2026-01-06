---
author: Cristian Livadaru
title: "Let the fun begin :)"
date: 2007-01-30
url: /2007/01/30/let-the-fun-begin/
slug: let-the-fun-begin
categories:
  - tech
draft: false
---
#

I love shopping computer parts, especially if it’s purpose will be to run a Server using Debian. Well I just picked up some parts from Ditech, not much, only 2 boxes ![:)][2]
Now that the assembly is ready and debian almost finished burning … I will start to install a base system and a raid5 on it, that will be all for today.


Problems during install …
Well I didn’t get to far the first problems was right after booting. The Debin installer seems to have problems recognizing the IDE (or the now so called PATA) CD-Rom on Core 2 Duo mainboards. Strange.
The solution is quite simple, I took the cd-rom out of the server, used one of my old IDE cases for external harddisks and abused that to connect the cdrom via usb ![:)][2] Worked. The next thing is, network card was not detected I “worked around” this problem by inserting some 3com I found at home, but the next thing was the sata controller. arggg.
Now I only have one more chance, downloading a daily snapshop of debian etch and hope that there is a new kernel on that one. That should solve my problems. If not …. I will have to continue searching tomorrow for solutions.

Problem solved, new Kernel find everything, system is up and running
