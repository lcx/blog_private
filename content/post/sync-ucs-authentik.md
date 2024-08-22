---
author: Cristian Livadaru
categories:
- tech
title: "Sync UCS LDAP to Authentik"
image:
date: 2024-08-22T18:53:39+02:00
slug: sync-ucs-authentik
summary: "We decided to use Authentik as our SSO solution, but we need to sync
    the users from our UCS LDAP to Authentik. The LDAP sync is not that hard, but
    there are some pitfalls to look out for to getting the right values mapped
    from LDAP to Authentik."
tags:
- ldap
- ucs
- authentik
- sso
draft: false
---
We decided to use Authentik as our SSO solution, but we need to sync
the users from our UCS LDAP to Authentik. The LDAP sync is not that hard, but
there are some pitfalls to look out for to getting the right values mapped
from LDAP to Authentik.

## Some preparations
In order to be able to sync the email addresses of the users, we need custom
property mapping in authentik.
To accomplish this, in the admin interface under Customization -> Property Mappings
click on create and enter these values:
- Name: UCS LDAP: Email
- Object field: email
- Expression:

```python
try:
    return ldap.get("mailPrimaryAddress")
except:
    return ''
```

This is needed because the email address of the user is stored in the UCS LDAP
under the attribute `mailPrimaryAddress` and you need to tell authentik how to find it.

## Create a LDAP Search user
You will need some LDAP user to access the UCS LDAP.
Univention has you covered with the documentation for this: [Cool Solution - LDAP search user / simple authentication account](https://help.univention.com/t/cool-solution-ldap-search-user-simple-authentication-account/11818)

## Configure the LDAP server
Go to the Authentik admin panel and add a new LDAP server under Directory -> Federation and Social login,
create a new entry with the name UCS, or whatever name you like.
I have enbaled the following options:

- Update internal password on login
- Sync users
- Sync groups

I did not enable the User password writeback option as I don't want the password
changes from authentik to be sent to the LDAP server.

As for the LDAP server, since I'm running this through a tailscale tunnel,
I'm connecting direct to the non ssl LDAP port: `ldap://100.65.0.3:7389`

Now to the LDAP configuration:

- Bind CN: `uid=LDAPsearch,cn=users,dc=example,dc=com` <- This is the LDAP Search user you created in the previos step.
- Bind Password: The password for the LDAP Search user
- Base DN: `dc=example,dc=com` <- This is the base DN of your LDAP server

If you are not sure about the Base DN, you can check it by running the following command on the UCS server:

```bash
univention-ldapsearch -LLL uid=cristian '*' '+' | grep dn
```
Which will return something like this: `dn: uid=cristian,cn=users,dc=example,dc=com`
this means that the Base DN is `dc=example,dc=com`.

### LDAP Attribute mapping
#### User Property Mappings

Select the following attributes to be mapped:
- authentik default OpenLDAP Mappgin: cn
- authentik default OpenLDAP Mappgin: uid
- UCS LDAP: Email <- This is the custom mapping we create earlier.

#### Group Property Mappings

Here you select just the authentik default OpenLDAP Mappgin: cn

- Addition User DN: `cn=users`
- Addition Group DN: `cn=groups`
- User object filte: `(objectClass=inetOrgPerson)`
- Group object filter: `(objectClass=posixGroup)`
- Group membership field: `uniqueMember`
- Object uniqueness field: `sambaSID`

The Group membership field took me a bit to figure out. I was going to path of
finding the group via user which means I wanted to use the `memberOf` attribute,
but it works the other way around, it search the users based on the imported groups!

## Testing
Before trying a test, I highly recomend to disable your SMTP server or block mails somehow.
If something isn't right in the configuration, authentik will send out a lot of emails if you have
many groups / users in the LDAP server. I ended up with a whopping 8000 emails in my inbox.

To trigger the sync manually enter the docker container and start the sync.

```bash
docker exec -it authentik /bin/bash
ak ldap_sync ucs
```
That's it! Have fun with your authentik synced LDAP users and groups.
