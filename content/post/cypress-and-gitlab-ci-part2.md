---
author: Cristian Livadaru
categories:
- webdev
date: "2018-07-24T10:34:58Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1429497419816-9ca5cfb4571a?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=cce7231fc568594a3fc6b7f21fbc7b03
slug: cypress-and-gitlab-ci-part2
summary: In the second part, I'll show you how to set up gitlab CI to deploy your
  locomotive CMS App and run tests on it.
tags:
- webdev
title: Testing websites with cypress and GitLab CI - Part2
---


**Update 2019-07-11: I have updated the [cypress + gitlab CI](https://lcx.wien/blog/cypress-gitlab-ci/) setup on my company blog, please refer to the updated version which can be found here [[2019 update] Using Cypress in GitLab CI](https://lcx.wien/blog/cypress-gitlab-ci/)**

In the [first part](__GHOST_URL__/testing-websites-with-cypress-and-gitlab-ci/) I showed you how to set up your first specs with cypress. 
Now let's get this running in a CI so you can have your great new specs run automatically after each git push. 

## Automate it
Since I'm using gitlab and gitlab CI this is what I will focus on but it should be very simple to adapt it to something else. 

First, let's start with a package.json you can either create one by running npm init or just use this as a template and update accordingly. 

```json
{
  "name": "somesite",
  "version": "0.0.1",
  "description": "Somte Site I am testing",
  "main": "index.js",
  "scripts": {
    "test": "./node_modules/.bin/cypress run"
  },
  "repository": {
    "type": "git",
    "url": "git@git.lcx.at:foo/bar.git"
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "cypress": "^3.0.2"
  }
}
```

run `npm install` and you are all set with the cypress part. 
run `npm test` and watch your tests run headless locally after which you can watch the videos that cypress will record.

### Gitlab CI

#### The Docker Images 
Here is the tricky part, since this is a [locomotive CMS](https://www.locomotivecms.com/) project which needs ruby and several gems + cypress.
Starting your CI image of the ruby:2.3 Docker image and adding everything needed for cypress (nodejs, and some other Debian packages) after which you install all the needed gems to be able to run wagon sets you back about 30 min on a slower CI.
So I will spare you that part and present you my final Docker image ([lcxat/ruby-wagon-cypress](https://hub.docker.com/r/lcxat/ruby-wagon-cypress/)) which comes with everything you need. 
You can find the [sources on our gitlab](https://git.lcx.at/lcx_at/ruby-wagon-cypress)

This Docker image is based on ruby:2.3, it will install some Debian packages needed for cypress and also install node.js.
It also uses a Gemfile and bundler to install all the gems needed for wagon, make sure to either have the same gem versions or to create a new docker image with the correct gem versions else you will have issues when trying to deploy from wagon in CI.

#### Create a new site in locomotive CMS
Create a new site in locomotive CMS and a new user which will be allowed to deploy to this site. 
Add all these details in a `deploy-testing.yml`


```
testing:
  host: cms.example.com
  handle: site-autotest
  email: foo@example.com
  api_key: APIKEY
```

**Do NOT enter your APIKEY in this file** instead leave the word APIKEY as is, it will later be replaced during the CI run.

#### The gitlab-ci config

To enable gitlab-ci, create a .gitlab-ci.yml file

```
image: lcxat/ruby-wagon-cypress

before_script:
  - sed -e s/APIKEY/$LOCO_API/g config/deploy-testing.yml > config/deploy.yml
  - bundle exec wagon deploy testing -v -d

cypress:
  script:
    - npm test
  artifacts:
    paths:
      - /builds/<group>/<project>/cypress/screenshots/
      - /builds/<group>/<project>/cypress/videos/
```

You need to add a new variable in gitlab called LOCO_API (You can find it in your project -> Settings -> CI/CD -> Variables 

![2018-07-24_14-15-07](__GHOST_URL__/content/images/2018/07/2018-07-24_14-15-07.png)

Here you will have to add the Locomotive CMS API Key for the newly created user (You can get that after logging in with the user, click on your name, Account settings -> API).

The before_script in the gitlab-ci config will replace the APIKEY in the deploy configuration with the variable value from gitlab. 

If you want to be able to download the recordings and screenshots, you need to tell gitlab where the artifacts will be saved. 

```
  artifacts:
    paths:
      - /builds/<group>/<project>/cypress/screenshots/
      - /builds/<group>/<project>/cypress/videos/
```

Replace group and project with the values of your group and project.

#### Fix the package.json

Since cypress was installed in `/` on the Docker image, change your package.json to run the tests from / instead of ./

```
  "scripts": {
    "test": "/node_modules/.bin/cypress run"
  }
```

## Push and watch the magic

What will happen now after you push a new branch is that gitlab will use wagon to actually deploy the site after which it will run through the specs using the real deployed site and create recordings of the test runs.
After moving the heavy lifting of package and gem installation to the Docker image a CI run now finishes in under 2 min. 

## Where to go next

Things that you might want to look at: 

* use a different baseUrl in cypress.json based on the environment (local testing on DEV vs. CI testing
* Dynamically create and drop test site, something like a database cleaner.
* check video issues, somehow the videos are pretty blank at first and then don't really seem to finish. 
* maybe even add an option to deploy to production from within gitlab/mattermost once the specs pass.

I hope this will help other wanting to automaticaly test their locomotive CMS projects.

