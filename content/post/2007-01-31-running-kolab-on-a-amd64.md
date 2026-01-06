---
author: Cristian Livadaru
title: "Running Kolab on a AMD64"
date: 2007-01-31
url: /2007/01/31/running-kolab-on-a-amd64/
slug: running-kolab-on-a-amd64
categories:
  - tech
draft: false
---
#

To get Kolab running on a 64bit system, compile the source on a 32bit system or if you have, like in my case, a running kolab that you want to migrate then no compilation is needed. Just install the 32bit libs (apt-get install ia32-libs) and kolab is ready to go.
Don’t forget to add users/groups/startup scripts to the new 64bit system.
Now I just have to get rid of the stupid “User Deleted, awaiting cleanup…” message, which has nothing to do with amd64, this message is there since Kolab was installed and a user deleted.
