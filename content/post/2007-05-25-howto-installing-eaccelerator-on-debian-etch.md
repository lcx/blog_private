---
author: Cristian Livadaru
title: "[HowTo] Installing eAccelerator on Debian etch"
date: 2007-05-25
url: /2007/05/25/howto-installing-eaccelerator-on-debian-etch/
slug: howto-installing-eaccelerator-on-debian-etch
categories:
  - tech
draft: false
---
#

This works for php4 and php5, apache1.3 and 2!

first get php5-dev (or php4-dev, depending on what you use)
apt-get install php5-dev

get eaccelerator from [here][1] and unpack it.

```bash
cd eaccelerator-0.9.5
phpize
./configure
make
make install
```

 [1]: http://bart.eaccelerator.net/source/0.9.5/eaccelerator-0.9.5.tar.bz2

create the eaccelerator cache directories
```bash
mkdir /tmp/eaccelerator
chmod 0777 /tmp/eaccelerator
```

and add this to your php.ini (in my case: /etc/php5/apache2/php.ini )

```

extension=eaccelerator.so
eaccelerator.shm_size=64
eaccelerator.cache_dir=/tmp/eaccelerator
eaccelerator.enable=1
eaccelerator.optimizer=1
eaccelerator.check_mtime=1
eaccelerator.debug=0
eaccelerator.filter=
eaccelerator.shm_max=0
eaccelerator.shm_ttl=0
eaccelerator.shm\_prune\_period=0
eaccelerator.shm_only=0
eaccelerator.compress=1
eaccelerator.compress_level=9
eaccelerator.allowed\_admin\_path=/path/to/control.php
```

adjust the memory to whatever you like.
Copy the control.php to whatever path you like (must be some htdocs accessible path) and set the path in eaccelerator.allowed\_admin\_path= …
edit the file and user/password.
now restart apache and you are done! go to the link where control.php is and check if you can login and if it works.
