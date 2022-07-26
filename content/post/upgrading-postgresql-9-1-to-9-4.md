---
author: Cristian Livadaru
categories:
- sysadmin
date: "2018-04-27T17:17:47Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1515526996020-12f6c0a386d0?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=8d8153a5192287f68327bfb948746fcb
slug: upgrading-postgresql-9-1-to-9-4
summary: |-
  Happy times with locales during a simple upgrade

  Error: The locale requested by the environment is invalid.
  Error: Could not create target cluster
tags:
- sysadmin
title: Upgrading PostgreSQL 9.1 to 9.4
---


Of course when you are in the middle of an upgrade of three servers, some huge shit hits the fan when you are not expecting it. 
Here we have postgres, I love postgres and the issue isn't really a postgres issue. 

`pg_upgradecluster 9.1 main`

and here you go ... 

```
Stopping old cluster...
Disabling connections to the old cluster during upgrade...
Restarting old cluster with restricted connections...
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
    LANGUAGE = "en_US.UTF-8",
    LC_ALL = (unset),
    LC_CTYPE = "UTF-8",
    LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Error: The locale requested by the environment is invalid.
Error: Could not create target cluster
```

oh the great f\*ing world of locales. Really? That's what just ruined your evening. Almost as much fun as Timezones.

`export LC_CTYPE=en_US.UTF-8 export LC_ALL=en_US.UTF-8`

and retry `pg_upgradecluster 9.1 main`

ah great, locales and you are friends again. Happy upgrading. 
Thx for the hint: https://gist.github.com/dideler/60c9ce184198666e5ab4

