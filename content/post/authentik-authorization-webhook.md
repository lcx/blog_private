---
author: Cristian Livadaru
categories:
- tech
title: "Authentik Authorization Webhook"
image:
date: 2024-10-02T14:38:33+02:00
slug: authentik-authorization-webhook
summary: "We have a custom application that needs to authenticate users against
    Authentik, but we also need to assign this user to a group in Paperless NGX.
    To accomplish this, we will use the Authentik Notification Webhook."
tags:
- authentik
- webhook
- paperless
draft: false
---
## The Problem
We have a custom application that needs to authenticate users against Authentik,
but we also need to assign this user to a group in Paperless NGX. To accomplish this,
we will use the Authentik Notification Webhook.

Unfortunately, Paperless NGX does not have an API to search for users, this means
that I need to fetch all users and pick out the one that authenticated.
For a small installation this might work, for larger installations this might be too slow.

{{% notice info%}}
The current implementation presented here does not take paperless pagination into account. If you have a lot of users, you will need to implement pagination processing
{{% /notice %}}

## Some preparations
In order to process the webhook, I am using [N8N](https://n8n.io/) as the automation tool.
It is running locally on site and firewalled off from the internet, it's only accessible
through a tailscale tunnel.

## Create the Authentik Notification Webhook

### Create a notification transport
In Authentik, go to Events -> Notifiacation Transports and click on Create.
Give it a name, add the URL of the N8N webhook. In this case I don't use any authentication.

{{% notice warning%}}
Please however keep in mind that anyone able to access the N8N Webhook URL can trigger the group assignment and hance gather access to docuemnts in Paperless NGX that they might not have access to.
{{% /notice %}}

Again, in this particular case, it's not a problem because
I am actually assigning the user to a default group, any other custom groups will be
added manually.

{{< figure src="/images/2024/10/authentik-webhook.webp" caption="Authentik Notification Transport" >}}

### Create a notification
In Authentik go to Events -> Notification Rules and click create.
Chose the previously created transport and select severity "Notice".

{{< figure src="/images/2024/10/authentik-notification-rule.webp" caption="Authentik Notification Rule" >}}

### Create and bind a policy
Open the notification rule and create a new policy.

{{< figure src="/images/2024/10/authentik-notification-policy.webp" caption="Authentik Notification Policy" >}}
In my case the policy already existed, your view might look different.
What you need to do is to set these values:

* Action: Authorize Application
* Client IP: `ak_client_ip`
* App: `authentik Events`
* Model: `Event (authentik_events)`

{{< figure src="/images/2024/10/authentik-notification-policy-2.webp" caption="Authentik Notification Policy details" >}}

This will now trigger your webhook every time someone uses SSO to authenticate, it will not trigger on every
authentik login which is not what I want. I only want it to trigger if the user authenticates to an application.

{{% notice warning%}}
Be aware that it will trigger for **every** application that the user authenticates to and might cause a lot of traffic to your webhook.
{{% /notice %}}

## Create the N8N workflow
This is the final workflow that I ended up with.

{{< figure src="/images/2024/10/n8n-workflow.webp" caption="N8N Workflow" >}}

### Cleaning up the data
The data sent by Authentik is partially JSON, but the data containing which application the user authenticated needs conversion.
Here is some of the data that we have in the body:

```
"authorize_application: {
  'flow': '897...', 'scopes': 'email profile openid',
  'http_request': {
    'args': {
        ...
    },
    'authorized_application': {'pk': '177b8', 'app': 'authentik_core', 'name': 'paperless', 'model_name': 'application'}}"
```

To convert this to json so I can work with n8n, I used this bit of javascript:

```javascript
return items.map(item => {
  let validJsonString = item.json.body.body
    .replace(/'/g, '"')
    .replace('authorize_application:', '"authorize_application":');

  let jsonObject = JSON.parse(`{${validJsonString}}`);

  return { json: jsonObject };
});
```
Now I can check if the login for was for paperless or something else.

### Fetching the user
To fetch the user from Paperless NGX, I use the HTTP Request node and send a GET request.
It must contain an API Token in the header.

Here would be the same request with curl:

```bash
curl "https://paperless.example.com/api/users/" \
  -H 'Authorization: Token 1234567890abcdef1234567890abcdef12345678' \
  -H 'Content-Type: application/json; charset=utf-8'
```

This will return all users in paperless and also counters which would be needed for pagination.

```json
{
  "count": 10,
  "next": null,
  "previous": null,
}
```

The other nodes should be self-explanatory, I am splitting the `results` array and checking if
I have found the user that has logged in.
Once the user was found, I am checking if the user is already in the group, if not I am adding the user to the group.

{{% notice warning%}}
The paperless NGX API replaces the users group with whatever is sent via API, so I first need to fetch any existing groups and then add the new group to the list.
{{% /notice %}}


```javascript
if ($input.item.json.groups.includes(1)) {
  $input.item.json.newGroups = [];
}
else {
  $input.item.json.newGroups = $input.item.json.groups;
  $input.item.json.newGroups.push(1);
}

return $input.item;
```

### Update the groups
To update the groups, I am using the HTTP Request node again, this time with a PATCH request.
Using curl this would look like this:

```bash
curl -X "PATCH" "https://paperless.example.com/api/users/10/" \
             -H 'Authorization: Token abc123' \
             -H 'Content-Type: application/json; charset=utf-8' \
             -d $'{
      "groups": [
        1
      ]
    }'
```

And this is how the http request in n8n looks like:

{{< figure src="/images/2024/10/n8n-patch-paperless-user.webp" caption="N8N HTTP Request" >}}

## Conclusion
This is by far a not perfect solution and there is much improvement potential. It is
however a working solution that simplifies the administration of users in Paperless NGX.

## Credits
Thanks to [Carlo Alberto Scola](https://carloalbertoscola.it/) for his post on [Ntfy and Webhooks in Authentik](https://carloalbertoscola.it/2023/linux/how-to-setup-webhook-authentik-notification/)

### Used tools
* [N8N](https://n8n.io/)
* [Authentik](https://goauthentik.io/)
* [Paperless NGX](https://docs.paperless-ngx.com/)
* [Tailscale](https://tailscale.com/)
