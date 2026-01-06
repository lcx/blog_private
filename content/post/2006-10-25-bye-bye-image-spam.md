---
author: Cristian Livadaru
title: "Bye Bye image spam!"
date: 2006-10-25
url: /2006/10/25/bye-bye-image-spam/
slug: bye-bye-image-spam
categories:
  - tech
draft: false
---
#

Some might have noticed the increasing amount of new spam that comes as image. This makes it impossible for a spam-filter like spamassassin to filter anything since the content of the spam is hidden as image and the text in the mail is random or some pieces from lord of the rings.
The solution? OCR ! There is a nice plugin for spamassassin called [ocrtext][1]. This little plugin, among with some other tools will fight spam that comes as image. Also new tricks, like animated gifs which can bypass other ocr plugins, will be recognized by ocrtext. I have only done short testing. But I think next week I can say if it was successful or not since I recently got a lot of image spam, this really pissed me of so I finally decided to do something against it.

 [1]: http://antispam.imp.ch/patches/patch-ocrtext
