---
author: Cristian Livadaru
categories:
- webdev
date: "2018-07-24T09:26:23Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1517134191118-9d595e4c8c2b?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ&s=c52b0953fc1a1d157d35a4eba1fd7b59
slug: testing-websites-with-cypress-and-gitlab-ci
summary: Testing a web app is common practice but when it comes to simpler websites
  it is often overlooked which caused pain, pain which can be avoided by creating
  specs. Let me guide you through spec creation for simple web pages which we will
  then automate and have them run in gitlab CI.
tags:
- webdev
title: Testing websites with cypress and GitLab CI - Part1
---


If you are working with Rails projects you should have your tests in place (you really really want specs, trust me on this one) but when it comes to smaller projects, say a website, you probably neglected tests and you are not alone.
Here is one recent example of a company website, nothing too complicated, some pages, videos and the most important part, the contact form and of course without any specs.

Since Safari doesn't really handle input type="date" very good (actually not at all) we decided to go with a date picker and went with [pickadate.js](https://github.com/amsul/pickadate.js)
Tested the date picker locally, everything works as expected and deployed to production, on Friday. 
"It's just a date picker, what could possibly go wrong" 

![deploy](/images/2018/07/deploy.gif)

Well, apparently a lot. picdate.js adds a hidden `_submit` field which rails does not like at all (See [github issue](https://github.com/amsul/pickadate.js/issues/227#issuecomment-32119529)). 

```
expected Hash (got String) for param `date'
```

This is what happens after you submit the contact form with the new date picker which results in a "We're sorry" page. 

> Wait, why rails? I thought this was a simple website. 

Well, almost. We are using [locomotive CMS](https://www.locomotivecms.com/) for our Websites and locomotive CMS is written in rails. 
The local pendant is wagon which runs the website on your dev machine for development and takes care of the deployment, something like Capistrano with an integrated rails server. Unfortunately, the local wagon does not handle everything the same way as the production deployment so you might miss some issues locally.
Here is where some tests would have spared us the embarrassment of deploying a website with a broken contact form. 

## Enter cypress.io

I heard about cypress a couple of weeks ago during [We Are Developers 2018](https://www.wearedevelopers.com/congress/) if you are curious, here is the talk

<iframe width="560" height="315" src="https://www.youtube.com/embed/p38bIMC-YOU" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

This really is what you need to solve the problems about testing web pages by creating automated tests which run in a real browser but can also run headless which means you can run it on your favorite CI. 

### Installing cypress

I am assuming you are doing this on a Locomotive CMS project with wagon running on your dev machine, although at this point it really doesn't matter. 
In your project path run the installer for cypress

```
npm install cypress
```

after which you should add to your .gitignore

```
node_modules/*
cypress/videos/
```

You don't want the node modules in your git repo and also not the videos that cypress creates. Yeah, that's right, cypress creates videos of the tests it runs. How cool is that? 

Now that cypress is installed, go ahead and start it. 

```
./node_modules/cypress/bin/cypress open
```

which will start the cypress window but without any tests so far.

### Create your first test

Create a file called contactform.spec.js and save it in cypress/integration/ and add something for cypress to do/test. 

```javascript
describe('Submit a contact form', function() {
  it('submits a contact form', function() {
    cy.visit('https://foo.example.com/contact')
    cy.get('#name').type('Automated Test')
    cy.get('#phone').type('+431*****')
    cy.get('#email').type('foo@example.com')
    cy.get('#contact-form').submit()
    cy.get('h1').should('contain','Thank you for your message')
  })
})
```

let's break this down

```
cy.visit('https://foo.example.com/contact')
```

this instructs cypress to visit the page, quite obvious. 
Then it searches for input fields with the specified ID's `cy.get('#name')` searches for an input field with the id name after which it fills the field with data `type('Automated Test')` this will be done for all specified fields after which the form is submitted. 

```
cy.get('#contact-form').submit()
```

bear in mind that you have to provide the ID of the form and **not** the ID of the submit button!

Last but not least, check if some expected message is present. 

```
cy.get('h1').should('contain','Thank you for your message')
```

This is a first simple start but already solve your problem of checking if the form was submitted and the desired thank you page is shown. 
Of course, this can't confirm if the data was saved in the database and so on, but let's keep it simple for now.

If you now look at your cypress window, you can see your newly created spec. 

![2018-07-24_13-11-14](/images/2018/07/2018-07-24_13-11-14.png)

Click on run all specs and watch the magic happen. 

![mind-blown](/images/2018/07/mind-blown.gif)

This is all great, but wouldn't it be nice if specs just run after you push your code to gitlab? 
Well, you're in luck since this is exactly what I already did and I'll show you how to do this [in part 2 of this blog](__GHOST_URL__/cypress-and-gitlab-ci-part2/).

