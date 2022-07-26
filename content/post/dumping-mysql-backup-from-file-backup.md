---
author: Cristian Livadaru
date: "2017-12-19T11:12:38Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1507560461415-997cd00bfd45?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=cbd575f8d320bdd94b1f0574b6c5fe41
slug: dumping-mysql-backup-from-file-backup
summary: 'So you have backups in place but forgot to install a mysql backup? Don''t
  panic, it''s not the end of the world, except if you excluded the sql directory
  from your file backup, then go ahead an panic. '
title: Dumping mysql backup from file backup
---


## Server is dead

Your server crashed but you have the MySQL data files from the old server or even better the complete backup of the old server?

Well, this is a simple one, if you only have the MySQL data files, put them in /var/lib/mysql on a different/new server, start MySQL and run mysqldump to dump the content to files which can be moved to a new server.
This should be quite simple to install a similar server (VirtualBox, digital ocean, aws ...)
Ther might be some issues if the installed MySQL versions differ, I was about to go down this road when a much simple solution came to mind. 
If all the files from the crashed server are present and mounted, why not just chroot and start the old MySQL? 

## The Rescue 

All you need to do now is: 

1. Chroot into the directory where you have your files from backup `chroot /old/`
2. Start mysql `/etc/init.d/mysql start` or `systemctl start mysql`
3. Run mysqldump `mysqldump -a --opt somedb > somedb.sql`
4. repeat 3. for all databases
5. stop mysql `/etc/init.d/mysql stop` or `systemctl stop mysql`
6. Import the dumps to the new DB 
7. `mysql somedb < somedb.sql`

## Backup

But how did you even get into this mess? No MySQL backups? 
You should at least install automysqlbackup, it might not be the fasted (compared to [mydumper](http://centminmod.com/mydumper.html)) but it get's the job done. 
When using debian it's as simple as `apt-get install automysqlbackup` or `apt-get install autopostgresqlbackup` if you are running PostgreSQL.

