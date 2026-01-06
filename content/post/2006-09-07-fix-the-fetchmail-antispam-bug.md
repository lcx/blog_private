---
author: Cristian Livadaru
title: "Fix the fetchmail antispam bug"
date: 2006-09-07
url: /2006/09/07/fix-the-fetchmail-antispam-bug/
slug: fix-the-fetchmail-antispam-bug
categories:
  - tech
draft: false
---
#

Fetchmail has a feature where you can tell on what errorcode fetchmail should treat the mail as spam and discard it anyway!
Normaly fetchamil would not discard a mail if it wasn’t accepted, but in some cases, like when the sender domain is not valid the mail is rejected with error 450. The lcX mailserver for example does this which reduces spam a little bit. The problem is that fetchmail has a bug and will not discard the message, to fix this and remain using the debian packages, one could do this:

add a source repository in your sources.list, for example: deb-src ftp://debian.inode.at/debian-amd64/debian/ stable main non-free contrib
then apt-get update and apt-get source fetchmail
cd fetchmail-6.2.5
create a file called patch.txt with this content
```

--- fetchmail-6.2.5/sink.c	Wed Jan  5 17:39:00 2005     fetchmail-6.2.5-new/sink.c	Wed Jan  5 17:41:08 2005 @@ -594,9  594,18 @@   * no PS_TRANSIENT, atleast one PS_SUCCESS: send the bounce mail, delete the mail;   * no PS_TRANSIENT, no PS_SUCCESS: do not send the bounce mail, delete the mail */  {      struct idlist *walk;      int found = 0;      int smtperr = atoi(smtp_response);      for( walk = ctl->antispam; walk; walk = walk->next )          if ( walk->val.status.num == smtperr )   	{   		found=1;  		break;  	}
 -    if (str_find(&ctl->antispam, smtperr))      /* if (str_find(&ctl->antispam, smtperr)) */      if ( found )      {  	if (run.spambounce)  	 return(PS_SUCCESS);
```
Patch fetchmail:
patch -p1
