---
author: Cristian Livadaru
categories:
- tech
date: "2024-07-18T11:07:11Z"
title: "Generating let's encrypt wildcard SSL certificates with ISPConfig and DNS challenge"
image: /images/2024/07/ssl-cert.webp
slug: npm-wildcard-ssl-ispconfig
summary: "Generating wildcard SSL certificates with Let's Encrypt and DNS challenge
  is a bit tricky with ISPConfig. It could be very straight forward but there is a little bug
  in the ISPConfig API or the nginx-proxy-manager that calls the API. Here is how you can work around it."
draft: false
tags:
- ssl
- ispconfig
- letsencrypt
- nginx-proxy-manager
---

I never took the time to look into Let's Encrypt wildcard SSL certificates until now, always kept
postponing to look into the DNS challenge option and also din't expect that it would work with
ISPConfig.
The option to create SSL Wildcard certificates is very straight forward, you go to SSL Certificates in [nginx-proxy-manager](https://nginxproxymanager.com/),
click on Add Certificate, select DNS challenge and enter your wildcard domain name.
The DNS challenge will create a TXT record in your DNS zone and Let's Encrypt will check if this record exists.
If it does, you will get your wildcard certificate and everyone is happy.

## Configuring the ISPConfig user
First you need to create a new remote user in ISPconfig. Go to System -> Remote Users and click on Add new user, make sure to
check the "Remote" checkbox and select the "dns txt" permission.

## Creating the SSL wildcard certificate
Now in nginx-proxy-manager, go to SSL Certificates and click on Add Certificate.
Select DNS challenge, this will open a new field where you can select your DNS provider, chose ISPconfig after which you
will have to add the API URL, the username and the password.

```
dns_ispconfig_username = myremoteuser
dns_ispconfig_password = verysecureremoteuserpassword
dns_ispconfig_endpoint = https://ispconfig.example.com:8080/remote/json.php
```

Please note that the URL in the example is not complete, you need to add the `remote/json.php` part to the URL as well.

So far so good, now click save aaaaaaand cry.

```
API response with an error: Incorrect datetime value: '' for column `dbispconfig`.`dns_rr`.`stamp` at row 1 INSERT INTO
`dns_rr` (`server_id`, `zone`, `name`, `type`, `data`, `ttl`, `active`, `stamp`, `serial`, `sys_userid`, `sys_groupid`,
`sys_perm_user`, `sys_perm_group`, `sys_perm_other`) VALUES ('1', '2', '_acme-challenge', 'TXT',
'asdffd', '60', 'Y', '', '0', '1', '1', 'riud', 'riud', '')
```

This is clear if you look at the insert statement, the `stamp` field is empty and the database doesn't like that
because it's a datetime field and an empty string is not a valid datetime.

Inspecting the code of ISPconfig (thank you open source!) shows that it loads a template with default values.
The one for a TXT record is here `/usr/local/ispconfig/interface/web/dns/form/dns_txt.tform.php` and it contains this:


```php
'stamp' => array (
        'datatype' => 'VARCHAR',
        'formtype' => 'TEXT',
        'default' => '',
        'value'  => '',
        'width'  => '30',
        'maxlength' => '255'
),
```

This is what create the empty string in the insert statement.
Backup this file, remove the entry and try again. You can now enjoy your wildcard SSL certificates with ISPconfig!

I have created an issue with [ISPconfig](https://git.ispconfig.org/ispconfig/ispconfig3/-/issues/6747)

Later Edit (2024-07-19): The issue is actually coming from [certbot-dns-ispconfig](https://github.com/m42e/certbot-dns-ispconfig/issues/12)
was fixed but the version installed by `pip install` will get an old version that still contains this problem.
It seems that ISPconfig might integrate a fix on their side as well, so fingers crossed.

Photo by <a href="https://unsplash.com/@wocintechchat?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Christina @ wocintechchat.com</a> on <a href="https://unsplash.com/photos/woman-in-black-top-using-surface-laptop-glRqyWJgUeY?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
