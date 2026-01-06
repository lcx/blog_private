---
author: Cristian Livadaru
title: "Fighting with tinyMCE+iManager in S9y blog"
date: 2006-01-16
url: /2006/01/16/fighting-with-tinymceimanager-in-s9y-blog/
slug: fighting-with-tinymceimanager-in-s9y-blog
categories:
  - tech
draft: false
---
#

I have been trying the whole weekend to get tinyMCE with iManager to work in s9y.
I found a blog  about this but not realy helpful, the first problem was that you have to get the tinyMCE compressor also which isn’t mentioned in the documentation, and then read the iManager doc carfully.
Well I read the iManager doc 10 times but still the iManager didn’t load from the tinyMCE. For this you have to copy the mentioned files from the doc, but somehow it still didn’t work. Today finaly everything works but I don’t understand why.
The problem was the Language !!! If you use a langauage that TinyMCE doesn’t support, it won’t work!
