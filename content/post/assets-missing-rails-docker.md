---
author: Cristian Livadaru
categories:
- tech
date: "2020-03-31T11:28:31Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1494153695676-b3d8a5219535?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=2000&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ
slug: assets-missing-rails-docker
summary: So you've deployed your new shiny rails app as a fancy docker container in
  production ... but what's that? Where the f* are all the assets?
tags:
- rails
- docker
title: Assets missing in Rails Docker container
---


I've fallen for this several times and every time I forget about it, so time to put it in a blog post, next time I will google for this issue I might find my own post.

{{< figure src="/images/2020/03/wisdom_of_the_ancients.png" caption="xkcd comic \"Wisdom of the Ancients\"" >}}

## Enable Serve Static Files

All you have to do is to define the ENV variable `RAILS_SERVE_STATIC_FILES` to true to make rails server static files in production. Normally it would assume the web server will take over this job but since it's running out of a container the web server can't do that.

To workaround this just define this in your docker-compose.yml or however you define your ENV settings.

```
RAILS_SERVE_STATIC_FILES: 'true'
```

Thanks to cloud66.com for the post [Deploying Rails 6 Assets with Docker and Kubernetes](https://blog.cloud66.com/deploying-rails-6-assets-with-docker/)

