---
author: Cristian Livadaru
title: "Finaly, rejected mails for unexistsing users"
date: 2006-03-19
url: /2006/03/19/finaly-rejected-mails-for-unexistsing-users/
slug: finaly-rejected-mails-for-unexistsing-users
categories:
  - tech
draft: false
---
#

I think I had this small “problem” quite a long time. A few years I gues, actualy since I switched to Cyrus and this is quite a long time ago. 2002 maybee ?
Anyway I knew about that litle problem but it wasn’t so bad to put to much time in it and as I was trying the first time to fix it I had the problem that I didn’t know where to get the existing users from.
Oh… almost forgot to mention the smal problem I had. Postfix doesn’t know anything about the existing users from cyrus since there is no place where it should look for the users, only cyrus knows about it.
But since the switch to users in mysql this problem is solved, postfix can check the database to look for the users, so in main.cf change this value:

```

local\_recipient\_maps = $alias_maps, mysql:/etc/postfix/mysql-virtual.cf, mysql:/etc/postfix/mysql-accounts.cf
```

what this will do is check the alias_maps ( which I didn’t move to mysql, no time for this ) then check the aliases created by web-cyradm in mysql and the rest of the users created by web-cyradm and that’s all.
here is my account.cf

```

#
# mysql config file for alias lookups on postfix
# comments are ok.
#

# the user name and password to log into the mysql server
hosts = localhost
user =
password =

# the database name on the servers
dbname =

# the table name
table = accountuser

#
select_field = username
where_field = username
additional_conditions = and block = ’0′
```
