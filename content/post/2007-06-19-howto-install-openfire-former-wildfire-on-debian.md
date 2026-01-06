---
author: Cristian Livadaru
title: "HowTo install openfire (former wildfire) on Debian"
date: 2007-06-19
url: /2007/06/19/howto-install-openfire-former-wildfire-on-debian/
slug: howto-install-openfire-former-wildfire-on-debian
categories:
  - tech
draft: false
---
#

Note: This has been done on a Debian Sarge installation but it should work on Etch also, I will report if it does once I have done it, sometime this week.
I found this [post on howtoforge][1] and it helped me alot.

 [1]: http://www.howtoforge.com/forums/showpost.php?p=24163&postcount=3

First you need Java JRE, lucky me I had a deb package on my server from some other tests so I didn’t need to create a new JRE deb package.
Follow [this howto to create a debian][2] package so you can install JRE the debian way. Once you installed the JRE you can continue with openfire.

 [2]: http://wiki.serios.net/wiki/Debian_Java_JRE/JDK_installation

Download openfire from http://www.igniterealtime.org/downloads/index.jsp
download the tgz file, the rpm installation with alien didn’t work for me on a AMD64, will probably work for i386.
unpack it move it to /opt

tar -xzvf openfire\_3\_0_0.tar.gz
mv openfire /opt

You don’t need to install any mysql java connector as mentioned on howtoforge, openfire now comes with everything you need.
Create a new database and create the tables with the provided file.
for example: mysql -u  -p < /opt/openfire/resources/database/openfire_mysql.sql

Make sure openfire.xml is writeable:

`# chmod 777 /opt/openfire/conf/openfire.xml`

Now setup openfire over the webinterface: http://localhost:9090 or http://127.0.0.1:9090
or use whatever server it is running on instead of localhost.

Note: if you have something like this in your /etc/hosts file

`127.0.0.1 foobar localhost localhost.localdomain`

it won't work since it will try to connect with dbuser@foobar instead of dbuser@localhost which won't work!
change you /etc/hosts so that localhost is first!
