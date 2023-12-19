---
author: Cristian Livadaru
categories:
- tech
tags:
- docker
- gitlab
image: /images/2023/12/datacenter.webp
title: "Fixing GitLab CI: dial tcp: lookup docker no such host"
slug: gitlab-docker-no-such-host
date: 2023-12-19T11:41:42+02:00
summary: Another issue I keep encountering with project upgrades, which I tend to
  forget about, is that during the build phase on GitLab CI, the old dind (Docker in Docker)
  setup no longer works, resulting in a 'no such host' error message.
draft: false
---
## The issue
When running a GitLab CI build, you may encounter the following error message:
```
Server:
ERROR: error during connect: Get http://docker:2375/v1.40/info: dial tcp: lookup docker on 10.10.70.1:53: no such host
Cleaning up project directory and file based variables
00:01
ERROR: Job failed: exit code 1
```
This error is a result of an outdated setup in my GitLab CI and GitLab Runner configuration.
It's likely, actually it's certain, that I haven't updated the runners for some time.
Here's a look at the old `.gitlab-ci` file that leads to this error:

```yaml
image: docker:stable

variables:
  DOCKER_HOST: tcp://docker:2375
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""

services:
  - docker:dind
```

## The Solution
To resolve this issue, update your `.gitlab-ci` file and make the following changes:

```yaml
image: docker:stable

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""

services:
  - name: docker:24.0-dind
    alias: docker
```
In this updated configuration, we removed the DOCKER_HOST variable and changed the
Docker image version to docker:24.0-dind. Be sure to adjust the version accordingly
to match the current Docker image. It's important to use the -dind tag for the service.

By making these changes, you can resolve the 'no such host' error in your GitLab CI
builds and ensure compatibility with the latest Docker setup.
