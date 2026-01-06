---
author: Cristian Livadaru
title: "Kolab, a opensource Groupware solution"
date: 2006-12-17
url: /2006/12/17/kolab-a-opensource-groupware-solution/
slug: kolab-a-opensource-groupware-solution
categories:
  - tech
draft: false
---
#

Want a Mailsever for a office that does all out of the box with virusscanner, spamfilter? Well Kolab could be one thing you should look at. Due to the fact that it uses Postfix and Cyrus, there is no way you could compare the performance to an exchange server (also called by someone as the best harddisk Benchmark ). Well since I love debian as server distribution it was also the OS I chose for this installation. But unfortunately there are no Debian packages for Kolab but you can still use the sources. I found an [excellent HowTo][2] (in german). This explains step by step all you need. The biggest problem was that I had to compile all kolab packages from source. On the P3 500Mhz I had here to install it took 6 hours! so make sure you have a loooot of coffee and time to get this done. Apropos coffee, it’s time for a new one.
The next problem one might encounter is, like in my case, when you use the same machine to install the new server. How do you get the old mails for the old installation on the new one? Well if you have XEN installed somewhere it’s a matter of minutes to setup a new Virtual server, install cyrus on it and follow my [Howto to import the old mails][3] on the Xen Vserver. This might sound like a bit of to much work, but it really is simple. Why didn’t I import the mails directly on the new Kolab server if the old one was also cyrus? Well, the old setup was a bit different and also a different cyrus version so I didn’t want to mess up to much with Kolab so I thought this would be the easiest way and all went out perfect.
But wait, now I still don’t have any of the old mails on the new Kolab installation. Well for this task you could use imapsync. I used it like this: imapsync –host1 192.168.0.101 –user1 foo –host2 localhost –user2 –authmech1 LOGIN –password1 foobar –password2 foobar –noauthmd5 –subscribe
Caution! if other users are logged in the machine where you start imapsync you should not user –password1 and –password2 since one could see the password in the process list. Refer to the imapsync manual and use the version where it reads the passwords from file!
Don’t forget the –subscribe option else any folder from the old server will not be shown on the new one, they will be imported and one could manually subscribe with thunderbird or a webmail, but for some users this task could be to complicated so make their (and finally you life) easier because I bet you will not be very pleased to hear “Oh my good, where are all my mail folders” from all users you have!
One final thing … if anybody is interested in installing it on a debian 3.1 on x86 platform, check the download locations carefully! There ARE binaries for debian! And you won’t have to wait 6 hours for compilation, like me, just because you where to fucking blind to see the ix86-debian-3.1 folder! arggg… I could punch myself for this. If you still didn’t find it, try [here][4].

 [2]: http://activmedia.ch/groupware1.php
 [3]: https://web.archive.org/web/20090105162233/http://livadaru.net/cristian/wiki/index.php/CyrusMove
 [4]: http://ftp.belnet.be/packages/kolab/server/release/kolab-server-2.0.4/ix86-debian3.1/
