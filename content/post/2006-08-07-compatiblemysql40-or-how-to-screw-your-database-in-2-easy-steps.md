---
author: Cristian Livadaru
title: "compatible=mysql40, or how to screw your database in 2 easy steps"
date: 2006-08-07
url: /2006/08/07/compatiblemysql40-or-how-to-screw-your-database-in-2-easy-steps/
slug: compatiblemysql40-or-how-to-screw-your-database-in-2-easy-steps
categories:
  - rant
  - tech
draft: false
---
#

Yes once again I had nothing better to do then move servers, fuck and today it wasn’t even raining.
Ok I came across a lot of problems as usual, one was that I decided not to use debian testing anymore, I wanted only stable !
One of the problems was that stable had mysql4.0 and my old database was 4.1 and of course there where problems while trying to import the database, but hey, there is a nice parameter –compatible=mysql40 sounds like exactly what I needed …
After I finished the server almost I found out what “compatible” means for the sickheads who implemented this parameter.
“compatible” means that this line:
\`object\_id\` int(11) NOT NULL auto\_increment,
will be transformed into this:
\`object_id\` int(11) NOT NULL default ’0′,

notice the little difference ? arggggg!
