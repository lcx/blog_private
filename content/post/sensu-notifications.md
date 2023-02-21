---
author: Cristian Livadaru
categories:
- tech
tags:
- sensu
- monitoring
image: /images/2023/02/alert.jpg
title: "Sensu Notifications"
slug: sensu-notifications
date: 2023-02-21T06:48:42+02:00
summary: Notifications in sensu can be complicated, but sometimes you just
  need to think out of the box. Maybe there are better ways to distribute
  the notifications. Just send them to some central place where you have 
  more control on distributing the notifications. While you could do this in 
  sensu, it definitely is a pain in the ass to constantly run ansible to deploy
  the changes.
draft: true
---
I've been using sensu for a long time in combination with Ansible. It can get
tricky sometimes, especially since you can't just log in to a server and add
new monitoring. Sensu did break my heart a little when switching from ruby to
Go, but it's all forgiven and forgotten ... almost ... Lately, I've been having
issues with the notifications however, not that it doesn't work as it's
supposed to, but rather that it's a bit complicated to add complex logic for
alerting. As long as you want notifications and that's it, you're fine, but
imagine the scenario: Client A has a special SLA with 24/7 support, some things
are super critical and do require immediate action, while a high CPU load is
probably nothing you want to be wakened up at 3 in the morning. Also, imagine
adding multiple people so that not a single person gets all the alerts and add
in some escalations. You could probably accomplish this by using something like
[PagerDuty](https://pagerduty.com) but why not waste a lot more time and roll
out your own stuff, right? 

## Apprise My first approach was to send notifications to
[Apprise](https://github.com/caronc/apprise), Apprise has one API to receive a
notification and can then send it to one or multiple other services (Pushover,
Pagerduty, Slack, Mattermost, Discord, Telegram ... ) so it makes sense to send
the notification to Apprise directly and have it distributed there to one or
multiple services/people. For this, I've created the
[sensu-apprise-handler](https://github.com/lcx/sensu-apprise-handler) which you
can download from [GitHub](https://github.com/lcx/sensu-apprise-handler) which
might be a bit messy but I'm very very new to Go. To test it out you can do the
following: 

```bash
cat testing/data/lcx-event.json |SENSU_APPRISE_KEY=example SENSU_APPRISE_WEBHOOK_URL=http://notify.foo.com go run main.go -t "cris,high"
```
and I just noticed I forgot to add some test events, you could probably borrow
some from the
[sensu-go-pushover-handler](https://github.com/nixwiz/sensu-go-pushover-handler/tree/main/sample_events)
While this is all good and nice, the Tagging alone is not enough to accomplish
what I want and also I either don't understand how Apprise handles tags or
[there's a bug](https://github.com/caronc/apprise-api/issues/103) So how could
I accomplish this more dynamic processing of notifications? 

## N8N This might be something that sounds completely like the wrong tool to
accomplish alerts but stay with me for a moment. [N8N](https://n8n.io/)
advertises itself with "Workflow automation for technical people" I've been
using it extensively in the past year and there's a lot that you can do with
it. One thing you have to bear in mind however, is as soon as you add something
in between sensu and the alerting, be it n8n or something you code yourself,
there's always a chance you can add bugs or maybe n8n crashes and then all your
alerting is for nothing. Keep this in mind and add special checks with other
ways of notifications for core services like this, but once you have that
covered, the only limit to what you could do are almost limitless. Here's what
I'm trying to accomplish. 
* Separated SLA for different clients
* Separated Alert levels for specific services
* Calendar-based notification of people
* Escalations if no action was taken.

For now, all my alerts just run into n8n, and depending on the company the
alerting differs. 

{{< figure src="/images/2023/02/n8n-sensu-workflow.png" caption="Notification Workflow in n8n">}}

But what I rather want to accomplish would be something like this. 

{{<mermaid align="left">}}
flowchart TD;
  webhook --> getClient --> getClientSla --> inSla
  getClient -- unknown --> alertUnknown(Alert unknown client)
  getClientSla <-.-> seaTable[(SeaTable)]
  inSla{Client in SLA Times} -- no --> endProcessing
  inSla -- yes --> fetchAlertLevel(Fetch alert level)
  fetchAlertLevel <-.-> seaTable
  fetchAlertLevel --> apprise(Trigger Apprise API)
{{< /mermaid >}}

Here I would use [SeaTable](https://seatable.io/en/) for saving my
configuration regarding clients, SLA times, and allert levels for specific
services. Not sure yet if I will do the fetching and processing of the tags
from Seatable within n8n or if I'll just spin up a ruby microservice in Docker
just for this task. 

Did I just say microservice? 

{{< figure src="/images/2023/02/microservices.jpg" caption="We all love microservices, right?">}}

Guess this will be my project for the next few days/weeks/months... let's see
where this will lead.
