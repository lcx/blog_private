---
author: Cristian Livadaru
categories:
- tech
date: "2017-12-22T12:42:17Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1466096115517-bceecbfb6fde?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=2bb3229346cba7691c378132bab4279e
slug: migrating-imap-accounts-to-zimbra
summary: 'Having to move ~ 180 Mail accounts from an older IMAP server to Zimbra (open
  source version) I though I would document the process if anyone else finds themself
  in this situation. '
tags:
- linux
- zimbra
title: Migrating IMAP accounts to Zimbra
---


## Preparation
* Backup!
* Get users to clean up mailboxes, won't help but worth a try
* Change default COS on Zimbra to have no quota during the import
* test the import several times before going live

## Creating users in Zimbra

Creating 180 Users by hand would be insane and I really like to automate things since automation saves us so much time.

[![Pass the salt](https://imgs.xkcd.com/comics/the_general_problem.png)]

In this case, it's really worth the effort. Since I had a CSV list of all old emails and names I came up with a short ruby script to create a shell script which does user creation and also sets the user to "force password change" after the first login.

```ruby
require 'csv'
outfile = File.open('create_users.sh', 'w')
CSV.foreach("./mail_users.csv") do |row|
  name       = row[0].split(',')
  last_name  = name[0].strip
  first_name = name[1].strip
  email      = row[1].delete("\r")
  password   = "**SOME PASSWORD HERE**"
  outfile.write "zmprov ca #{email} #{password} cn \"#{first_name} #{last_name}\" displayName \"#{first_name} #{last_name}\" zimbraPrefFromDisplay \"#{first_name} #{last_name}\" givenName \"#{first_name}\"\n"
  outfile.write "zmprov ma #{email} zimbraPasswordMustChange TRUE\n"
end
outfile.close
```

This reads all users from the CSV file and creates a new shell script with zmprov ca (create account) and all needed parameters to create a new account.

## imapsync

There is a great tool for syncing IMAP accounts called [imapsync](https://imapsync.lamiral.info/). Don't be fooled by the web page, the tool is awesome!
But it takes some playing around with it to figure out all the options. There is a [guide from Zimbra](https://wiki.zimbra.com/wiki/Guide_to_imapsync) regarding the parameters but that didn't quite work for me (using Zimbra 8.8) so here are the parameters I used to migrate from an old Kolab installation (using Cyrus v2.3)

dump this into a shell script and call it sync.sh, we will call this script from within a wrapper script.

```bash
./imapsync \
  --buffersize 8192000 \
  --nosyncacls --subscribe --syncinternaldates \
  --exclude '(?i)\b(Junk|Spam|Trash)\b' \
  --regexflag 's/\\\\(?!Answered|Flagged|Deleted|Seen|Recent|Draft)[^\s]*\s*//ig' \
  --regexflag 'tr,:"/,_,'
  --regextrans2 's,:,-,g' \
  --regextrans2 's,\*,,g' \
  --regextrans2 's,\",'\'',g' \
  --regextrans2 's,\s+(?=/|$),,g' \
  --regextrans2 's,^(Briefcase|Calendar|Contacts|Emailed Contacts|Notebook|Tasks)(?=/|$), $1 Folder,ig' \
  --host1 "192.168.0.1" --host2 "localhost" --port2 7143 \
  --user1 "$1" --user2 "$1" \
  --password1 "$2" --password2 "$2" \
  --regextrans2 's,\",-,g' \
  --regextrans2 's,&AAo-|&AA0ACg-|&AA0ACgANAAo-(?=/|$),,g' \
  --delete2 \
  --logfile $3
```

### The imapsync parameters
let's break it down, I won't go into detail of every parameter and most of them are explained in the [zimbra wiki](https://wiki.zimbra.com/wiki/Guide_to_imapsync) as well.

A big warning regarding `--delete2`
Only use this parameter if you did not enable mail delivery yet to the zimbra server! Otherwise you will delete your freshly received mails from the zimbra server since these Mails are not on your old server!
You have been warned!

* regexflag: this one is very important especially if users worked with tags in Thunderbird for example and use forbidden characters, these are :/" according to [zimbra docs](https://www.zimbra.com/desktop7/help/en_US/Tags_and_flags/Using_tags_to_classify_mail_messages.htm).
For some reason, the recommended regex that should avoid all nonstandard system flags didn't work for me and since I had no time to debug the regex I added the option to just replace "forbidden" characters: `--regexflag 'tr,:"/,_,'`
* regextrans2: these rewrite the folder names to replace forbidden character which Zimbra can't handle. This is very important otherwise emails from those folders won't be imported.
* delete2: this deletes emails on the Zimbra server which aren't on the first server anymore. This is useful / needed if an import was already done and users still work on the first server.
* logfile: well, we want to log the process.

I removed the option `--nofoldersizes ` since I like to see stats after the import to know if something might have got skipped.

I also removed the recommended `--skipheader 'X-*' \` setting as this lead to a lot of skipped messages that where not synced from the old IMAP server to Zimbra, with this error message:

```
Host1 INBOX/20660 size 8400 ignored (no wanted headers so we ignore this message. To solve this: use --addheader)
```

### Where to look for errors

If you get messages regarding not synced emails similar to this one:

```
couldn't append  (Subject:[Some Mail here]) to folder ... NO APPEND failed
```

check the `/opt/zimbra/log/mailbox.log` and you will likely find the source of the problem, in this case, a flag containing `:` -> `imap - APPEND failed: invalid name: sw:foobar` here is where the `--regexflag 'tr,:"/,_,'` would come in and solve this.

## Starting the import

I whipped up a ruby script as a wrapper around the `sync.sh` shell script.
Since I would like to know what's going on without having to log in an see if things are running, the script will use the slack-notify gem to push notifications to Slack, it might be a bit overkill but works for me.

```ruby
require 'csv'
require 'slack-notifier'

notifier = Slack::Notifier.new "---> YOUR SLACK WEBHOOK GOES HERE <---"
notifier.ping "Starting import"

email = ""
begin
  CSV.foreach("./mail_users.csv") do |row|
    email    = row[1].delete("\r")
    password = row[2]
    password ||= "some password"
    logfile  = "#{email.gsub("@","-").gsub(".","_")}.log"
    notifier.ping "Starting import for #{email} at #{Time.now}"

    status   = system "./sync.sh #{email} #{password} #{logfile}"
    if status
      notifier.ping "Success: Import for #{email} done at #{Time.now}"
    else
      notifier.ping "Error: Import for #{email} returned an error at #{Time.now}, check logs #{logfile}"
    end
  end
rescue => e
  attachments=[
    {
      "fallback": "Crash at user #{email}",
      "color": "#aa0303",
      "title": "#{e.message}",
      "text": "#{e.backtrace.inspect}",
      "ts": Time.now.to_i
    }
  ]
  notifier.ping "<!channel> Importer crashed at user #{email}", attachments: attachments
end

notifier.ping "<!channel> Import done! 🎉"
```

Since I have passwords for some users where I won't be resetting passwords, I added them to the CSV file if no password was present we just use the default reset password for the import.

That's it, happy IMAP migration 🎉

