---
author: Cristian Livadaru
categories:
- tech
title: "{{ replace .Name "-" " " | title }}"
image:
date: {{ .Date }}
slug: {{ .Name }}
tags:
{{- if .Site.Params.comments }}
{{- if and .Site.Params.comments.host .Site.Params.comments.username }}
comments:
  host: {{ .Site.Params.comments.host }}
  username: {{ .Site.Params.comments.username }}
  id:
  blockedcomments:
{{- end }}
{{- end }}
draft: true
---
