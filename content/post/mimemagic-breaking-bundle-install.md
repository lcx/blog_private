---
author: Cristian Livadaru
date: "2022-05-18T12:35:44Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1495051964098-df2856bfee39?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VhcmNofDExfHxicm9rZW58ZW58MHx8fHwxNjUyODgzOTUx&ixlib=rb-1.2.1&q=80&w=2000
slug: mimemagic-breaking-bundle-install
title: mimemagic breaking bundle install
---


This is no new issue and most likely it will only be relevant to older rails projects, but since I faced the same issue again and meanwhile forgot what it was about and how it should be fixed, here a note to self.

For more details and an appropriate header image for this subject, check out Christine's Post on this issue: [What's up with mimemagic breaking everything?](https://dev.to/cseeman/what-s-up-with-mimemagic-breaking-everything-he1)

## The Error

While running bundle install

```
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
current directory: /bundle/gems/mimemagic-0.4.3/ext/mimemagic
...
Could not find MIME type database in the following locations:
...
Ensure you have either installed the shared-mime-info package for your distribution, or obtain a version of freedesktop.org.xml and set FREEDESKTOP_MIME_TYPES_PATH to the location of that file.
```

The answer is already in the error message, you need to install `shared-mime-info` which I did add to the `Dockerfile`

```bash
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends \
    vim cmake cron shared-mime-info && \
```



