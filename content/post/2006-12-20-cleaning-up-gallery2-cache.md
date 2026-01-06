---
author: Cristian Livadaru
title: "Cleaning up Gallery2 Cache"
date: 2006-12-20
url: /2006/12/20/cleaning-up-gallery2-cache/
slug: cleaning-up-gallery2-cache
categories:
  - tech
draft: false
---
#

I wondered why my Gallery2 database backup was so HUGE ! (3gigs of text!) That couldn’t be right. After I search a bit on menalto.com on the forum I found out that the cache was the problem. After deleting the cache, the same database had only 16MB ! That is quite a difference. Anyway, the cache has it’s useful part, else you could turn it of so I wrote a little script to clean up everything that is older then a week. The DB then still has about 200MB but that is not comparable to 3GB ! So here is my little script.

```php
 # which databases to clean up (g2cleanup@localhost needs access)
# grant select,delete on xxx.g2_CacheMap to g2cleanup@localhost identified by ' ‘
$g2DB = array(“db1″,”db2″,”db3″);
foreach ($g2DB as $db)
{
echo “connecting to $db …n”;
$connect = @mysql_connect(“localhost”,”g2cleanup”,” “);

# check if connection ok
if (!$connect)
{
die(‘Could not connect: ‘ . mysql_error());
}
$lastWeek=strtotime(‘now -7 days’);
$cleanup\_query = “delete from g2\_CacheMap where g_timestamp
```
