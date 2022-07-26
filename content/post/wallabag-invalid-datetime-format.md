---
author: Cristian Livadaru
categories:
- linux
- docker
date: "2021-07-19T15:19:43Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1575699914911-0027c7b95fb6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VhcmNofDJ8fEthbmdhcm9vfGVufDB8fHx8MTYyNjcxNTEwMA&ixlib=rb-1.2.1&q=80&w=2000
slug: wallabag-invalid-datetime-format
summary: This pesky little issue prevented me in adding a lot of links to wallabag,
  but as it turns out, the fix is really simple.
tags:
- linux
- docker
title: 'Wallabag: Invalid datetime format'
---


If you are encountering this error while trying to add new entries to wallabag, you might be hitting the `database_charset` issue mentioned in these two github issues:

* [https://github.com/wallabag/wallabag/issues/5116](https://github.com/wallabag/wallabag/issues/5116)
* [https://github.com/wallabag/wallabag/issues/4764](https://github.com/wallabag/wallabag/issues/4764)

The fix of changing the charset is described in the issues, but if you set up wallabag with caprover, you just need to define a new environment variable `SYMFONY__ENV__DATABASE_CHARSET` and set it to `utf8mb4` this will solve the issue for a caprover installation. A pull request was generated here: [https://github.com/caprover/one-click-apps/pull/466](https://github.com/caprover/one-click-apps/pull/466) 

