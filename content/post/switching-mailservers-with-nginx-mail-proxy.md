---
author: Cristian Livadaru
categories:
- sysadmin
- linux
date: "2018-03-02T13:23:07Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1500281781950-6cd80847ebcd?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=0fb6e97ae29c0e2e561c198f3d28a00e
slug: switching-mailservers-with-nginx-mail-proxy
summary: "Switching mailserver with lots of active users isn't an easy task. \nFirst
  you need to copy the mails to the new server and then get all the users to change
  mailserver settings at the same time to switch to the new server. "
tags:
- sysadmin
- linux
title: Switching mailservers with nginx as mail proxy
---


## Why switch Mailserver?

I had this old server running Cyrus mail with which I was happy for several years. But over the time there were some issues and also I wanted to consolidate all mail accounts on the new ispconfig server running with dovecot.
Dovecot and Postfix both support running with multiple server names and multiple SSL certificates in some way but that would imply that you could move all accounts at once to the new server which in itself is another huge task.
Wouldn't it be nice if we could migrate a couple of accounts and switch them over to the new server without the users needing to change something? 
Actually, nginx does just that perfectly!

## Enter nginx IMAP / POP Proxy

With nginx, you can set up an IMAP, POP, and even SMTP proxy, but I skipped the SMTP part since I let the users send the mail out through the old server, more about that later. 
My idea was to set up a nginx proxy in front of the old and new mail server, depending if the user was already migrated sent the user to the new server else send the user to the old server. 
In my case, I have a router in front of my servers so I can send the IMAP/POP ports to the proxy instead of the real server. If you don't have this, you would need to move your SMTP and IMAP server on a different port put nginx on the mail ports. 

### Installing the system 

Start with a plain Debian Jessie and install nginx-full + PHP.

```
apt install nginx-full php-fpm
```

Enable php in /etc/nginx/sites-available/default

```
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }
```

### Setup the Mail proxy

In your nginx.cof, add the setting for the mail proxy

```
mail {
  server_name lcx.at;
  auth_http  10.10.10.10/auth.php;
  proxy  on;
  proxy_pass_error_message on;

  imap_capabilities "IMAP4rev1" "UIDPLUS" "IDLE" "LITERAL +" "QUOTA";

  pop3_auth plain apop cram-md5;
  pop3_capabilities "LAST" "TOP" "USER" "PIPELINING" "UIDL";
  ssl_certificate /etc/ssl/commercial.crt;
  ssl_certificate_key /etc/ssl/commercial.key;
  ssl_session_timeout 5m;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
  ssl_prefer_server_ciphers on;
  
  server {
    listen      143;
    protocol    imap;
    starttls    on;
    auth_http_header X-Auth-Port 143;
    auth_http_header User-Agent "Nginx POP3/IMAP4 proxy";
  }


  server {
    protocol    pop3;
    listen      110;
    starttls    on;
    pop3_auth   plain;
    auth_http_header X-Auth-Port 110;
    auth_http_header User-Agent "Nginx POP3/IMAP4 proxy";
  }

  server {
    listen      993;
    ssl         on;
    protocol    imap;
    auth_http_header X-Auth-Port 993;
    auth_http_header User-Agent "Nginx POP3/IMAP4 proxy";
  }

  server {
    protocol    pop3;
    listen      995;
    ssl         on;
    pop3_auth   plain;
    auth_http_header X-Auth-Port 995;
    auth_http_header User-Agent "Nginx POP3/IMAP4 proxy";
  }
}
```

So what is it with this auth_http and why is it needed? 
You actually can skip the auth part, since we will be sending the request to the real IMAP server which will do the auth but you still need that auth script. The great thing about this script is that you can tell nginx which IMAP server to use based on the mail address. 


### The auth_http nginx script

If you just look in nginx.conf there is a link to the nginx wiki with an [example php script](http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript) (hence the php installation)
Place this auth.php in /var/www/html/

```php
<?php
/*
NGINX sends headers as
Auth-User: somuser
Auth-Pass: somepass
On my php app server these are seen as
HTTP_AUTH_USER and HTTP_AUTH_PASS
*/
if (!isset($_SERVER["HTTP_AUTH_USER"] ) || !isset($_SERVER["HTTP_AUTH_PASS"] )){
  fail();
}

$username=$_SERVER["HTTP_AUTH_USER"] ;
$userpass=$_SERVER["HTTP_AUTH_PASS"] ;
$protocol=$_SERVER["HTTP_AUTH_PROTOCOL"] ;

// default backend port
$backend_port=110;

if ($protocol=="imap") {
  $backend_port=143;
}

if ($protocol=="smtp") {
  $backend_port=25;
}

// NGINX likes ip address so if your
// application gives back hostname, convert it to ip address here
$backend_ip["old"] ="123.223.145.221";
$backend_ip["new"] ="10.10.10.40";

// Authenticate the user or fail
if (!authuser($username,$userpass)){
  fail();
  exit;
}

// Get the server for this user if we have reached so far
$userserver=getmailserver($username);

// Get the ip address of the server
// We are assuming that you backend returns hostname
// We try to get the ip else return what we got back
$server_ip=(isset($backend_ip[$userserver]))?$backend_ip[$userserver] :$userserver;

// Pass!
pass($server_ip, $backend_port);

//END

function authuser($user,$pass){
  // password characters encoded by nginx:
  // " " 0x20h (SPACE)
  // "%" 0x25h
  // see nginx source: src/core/ngx_string.c:ngx_escape_uri(...)
  $pass = str_replace('%20',' ', $pass);
  $pass = str_replace('%25','%', $pass);

  // put your logic here to authen the user to any backend
  // you want (datbase, ldap, etc)
  // for example, we will just return true;
  return true;
}

function getmailserver($user){
  // put the logic here to get the mailserver
  // backend for the user. You can get this from
  // some database or ldap etc
  $new_users = array("foo@example.com","bar@example.com");
  if (in_array($user, $new_users)) {
    return "new";
  } else {
    return "old";
  }
}

function fail(){
  header("Auth-Status: Invalid login or password");
  exit;
}

function pass($server,$port){
  header("Auth-Status: OK");
  header("Auth-Server: $server");
  header("Auth-Port: $port");
  exit;
}
```

You need to define your IMAP servers in $backend_ip
The authuser function would be used to authenticate the user. Since I don't really care as I pass it along to the real IMAP server it just returns "true" here.
But think at the possibilities for a second, if you don't have the plaintext passwords of all the users somewhere ... here is the place where you could actually automate everything.
Something like this: 

* User authenticates successfully
* Check DB if user is on the old server and if so
    * trigger some API to create new user on the new mail server
    * trigger imapsync to copy all emails (you would want to do this async!)
* so many more things come to mind

The other thing you need to change is the getmailserver function. If you are doing this manually then add each migrated email to new_users and nginx will pass the connection to the new mail server, otherwise, it will go to the old one. 

### The Mail migration

Before starting the migration make sure that the mail account exists on the new mail server with the **same** credentials as on the old server. 
Then if using postfix, tell postfix to send any new emails still reaching the old server over to the new one. 
For this, you can use the /etc/postfix/transport file and add either a single email or a whole domain and where postfix should send the emails. 

```
livadaru.net smtp:[10.10.10.10]
foo@example.net smtp:[10.10.10.10]
```

this would send all emails for livadaru.net via SMTP to 10.10.10.10 and the same for foo@example.net. 
This assures that any new mail will already reach the new mail server while the old ones are being copied. 

Create a sync.sh script to start imapsync

```bash
/usr/bin/imapsync \
  --buffersize 8192000 \
  --nosyncacls --subscribe --syncinternaldates \
  --exclude '(?i)\b(Junk|Spam|Trash)\b' \
  --regexflag 's/\\\\(?!Answered|Flagged|Deleted|Seen|Recent|Draft)[^\s]*\s*//ig' \
  --regexflag 'tr,:"/,_,' \
  --regextrans2 's,:,-,g' \
  --regextrans2 's,\*,,g' \
  --regextrans2 's,\",'\'',g' \
  --regextrans2 's,\s+(?=/|$),,g' \
  --regextrans2 's,^(Briefcase|Calendar|Contacts|Emailed Contacts|Notebook|Tasks)(?=/|$), $1 Folder,ig' \
  --host1 "lcx.at" --host2 "localhost" --port2 143 \
  --user1 "$1" --user2 "$1" \
  --password1 "$2" --password2 "$2" \
  --regextrans2 's,\",-,g' \
  --regextrans2 's,&AAo-|&AA0ACg-|&AA0ACgANAAo-(?=/|$),,g' \
  --pidfile "$3.pid" \
  --pidfilelocking \
  --logfile $3
  ```
  
  you can start the migration with: `./sync.sh email password logfile`
  
  ```
  ./sync.sh foo@example.com verysecurepassword foo@example.com
  ```
  
  Yes, I use the mail address as logfile name and also as PID file name. 
  This way checking logs is a bit easier and by using a non-standard PID file you can start multiple imapsync sessions at once. 
  Once you finished the migration of an account, add that mail address to the new_users array in the PHP file, from this point on the users will reach the new mail server and not the old one anymore. 
  Repeat until you migrated all users after which you can now tell them to start changing their mail settings. 
  
  ## Next Steps
  
  Add some syslog to the PHP file to keep track of which users are still coming in through the proxy or check the log files on the new server since the users will all show up as using the proxy IP. 
  Insist that the users change mail settings. 
  
  
  ## Some more things to consider
  
  If you did not proxy the SMTP connection then keep SPF in mind and set the SPF record accordingly. Don't forget to fix the MX records, you could actually do that as soon as you have added all emails to the postfix transport file.

