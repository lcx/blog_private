---
author: Cristian Livadaru
categories:
- tech
date: "2018-11-15T15:31:03Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1517061622894-119cfdf81ad0?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=ea1c7284572df22fbb3f735fcc6ad1ae
slug: fusionpbx-provisioning
summary: Reusing passwords is never a good idea and by default the fusionpbx setup
  would use the same user and password for all domains when provisioning.
tags:
- fusionpbx
- voip
title: Doing FusionPBX Provisioning the right way
---


All things are not bad though, then by default also FusionPBX checks that the domain matches the device domain, nonetheless if one customer knows other customers domains and also has the user/password for provisioning, it could try to enumerate MAC addresses and get a hold of other customers credentials.
Yes I know there are a lot of if's here but it is very simple to solve so why not solve it the proper way?

I will assume you already have provisioning enabled, if not got to the default settings and set the `enabled` setting under provisioning to `true` and also to `enabled`, otherwise the whole provisioning thing will not work.

![FusionPBX Provisioning enable](/images/2018/11/2018-11-15_14-29-55.png)

You might not know that you can override default settings for every domain, fusionpbx first uses the domain settings and if they are missing it will fail over to the default settings! It's awesome for what you need to set up separate provisioning settings for each client.
To accomplish this, go to advanced -> domain and click on the domain, not the edit pencil on the right, you have to click on the domain.

![Fusionpbx Domains](/images/2018/11/2018-11-15_15-30-34.png)

After you click on the domain, you click on the plus sign on the right side, this will allow you to create settings valid for this domain only!

![FusionPBX Domain Settings](/images/2018/11/2018-11-15_15-45-39.png)

Create settings for http_auth_password and http_auth_user if you want separate users for HTTP provisioning auth.

![2018-11-15_15-46-25](/images/2018/11/2018-11-15_15-46-25.png)

after you have done this, it should look something like this.
![2018-11-15_15-37-03](/images/2018/11/2018-11-15_15-37-03.png)

that's it, you have now created a custom http auth user + password that will be used for provisioning only for this domain.

Well, almost. You still need to tell fusionpbx which domain to use for provisioning, for this to work you will have to tell fusionpbx to use the current domain of each customer. You can do this by adding a separate setting for each domain, but this is duplicated work and nobody likes duplication.

This of course requires the provisioning template to not use hardcoded values in the provisioning settings but to use the variables. For a SNOM 7xx it would look like this:

```
<setting_server perm="RW">https://{$http_auth_username}:{$http_auth_password}@{$domain_name}:443{$project_path}/app/provision/index.php?mac={$mac}</setting_server>
```

It has to be `{$domain_name}` in order to fill the current domain in the provisioning URL.

## Enforcing domain filters
At first, I wanted to recommend to enable the `http_domain_filter` in the default settings but here is why this will actually screw you over quite bad and why you don't need it if you have set up separate passwords for each client.

1. NAPTR + A Records don't go well together. If you set an A record the NAPTR will stop working! Not sure if this is supposed to be that way or I did something wrong while testing.
2. You might either need SSL Certs for each client or a wildcard cert.

So, just set the `http_domain_filter` to false, use the main domain with valid CERT and DNS A records for provisioning.
If you set up domain level http_user + pass for provisioning, fusionpbx will check the values from the domain where the device is attached to. Even if a client knows a second domain and mac address of a device, they won't be able to use the password from their domain to fetch the provisioning data.
I think an example would help here but I did spend half a day testing and reading PHP code, who know me better knows that I don't do well with PHP.

## I've got a 404 error

If by any chance you encounter a 404 error with nginx version 1.12.1, don't freak out. Fusionpbx returns this by default when something is wrong during provisioning.

```
if ($error === "404") {
  header("HTTP/1.0 404 Not Found");
  echo "<html>\n";
  echo "<head><title>404 Not Found</title></head>\n";
  echo "<body bgcolor=\"white\">\n";
  echo "<center><h1>404 Not Found</h1></center>\n";
  echo "<hr><center>nginx/1.12.1</center>\n";
  echo "</body>\n";
  echo "</html>\n";
}
```

A good hint is to check syslog where you might find more useful information.
If you have a 404 error and no syslog then you have reached `resources/classes/provision.php` which returns 404 either if the device is not enabled `if($row['device_enabled'] != 'true')`  or `//if $file is not provided then look for a default file that exists` not quite sure when this happens.

## How to test this?

1. Use `curl` or `wget` to request the provisioning file, prevent using your browser since it might work if you are login even if the http auth credentials are wrong.
2. Check the output if the URL settings are correct
Domains transfers normally cause no downtime and no issues but if some registrar want's to play rough it can definitely cause some headache

## Thanks
Thanks go out to Aleksa Markovic for helping with this and setting up the test system and of course to Mark for creating fusionpbx.

