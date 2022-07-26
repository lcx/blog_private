---
author: Cristian Livadaru
categories:
- life
date: "2020-10-06T17:34:24Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1582265386170-93751daad557?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=2000&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ
slug: oh-the-irony
summary: This story needs a bit of a background from my time at high school for it
  to make any sense why this one little phone call made my day.
tags:
- life
title: Oh the irony
---


## Background about my high school time

When I was in Highschool (Not sure if translated correctly. Details about the HTBLuVA on Wikipedia [https://en.wikipedia.org/wiki/Höhere_Technische_Lehranstalt](https://en.wikipedia.org/wiki/H%C3%B6here_Technische_Lehranstalt)) my teachers would probably describe me as not the best pupil in the class. But if something sparked my interest, there was no stopping. Accounting and a lot of other subjects did not spark my interest.

This one 486 PC in the lab full of 286 PCs did however spark my interest. Nobody liked the 286 lab due to the slow PCs, but there was this one 486 which at that time was awesome. The only problem is, you couldn’t get on the internet with it. Things where different at that time, the network cards used coax cables and terminators (I think that’s how they were called) and the school used some NOVEL Network stuff which worked a bit different than today. To be able to access the internet, you would need to enter the magic command “TCP ON” in dos, which gave you an IP Address (looks like DHCP Servers were not a thing back then) after you had an IP, the full world of the internet was open. Well, this PC just gave me an error with this TCP ON command. But, I was interested, I wanted to access the internet, all other labs were full so I started a reverse engineering session which lasted probably hours? Days? I have no clue. I started to look where this command was and what it did. I have no clue how the hell I found out that it was a BAT script. I read the script and tried to figure out what it does, it was looking for some files in a directory. So I checked that directory, looked for files how the script would, and indeed it would not find any file for my machine. So I copied the TCP ON script, and forced it to use a specific file and which file do you choose when you have multiple to choose from? Well, obviously the last one.

## TCP ON

I started my modified script and here I was, with an IP, accessing the internet.

This went on for a couple of days until I got an email from someone that I was blocking his access to the Unix / Linux machines and what else ... I probably understood about 20% of what he was writing and honestly thought it was a mistake. Well, until at some point the schools IT Admins were behind me and asked me to step aside and checked my PC. Well, I didn’t think much about it, got a PC LAB Ban for a week? A month? Which itself I find very very stupid, blocking pupils from the PCs in an IT school. This reverse engineering session thought me much more than all the hours I got while at the school.

## Multi Tasking

Multi tasking wasn't really a thing back then. Since I wanted to download some totally legal stuff via FTP (we had huge printed lists of FTP servers where stuff was since google didn't exist), I had my account downloading stuff from the quick PC, of course with the monitor turned of so nobody could see that I was logged in on two PC's, this was technically not possible, to be able to do that, you needed two accounts and account sharing was strictly forbidden. Shout out to my friend Thomas who shared his account with me and as thank you for this he received a one week ban (I was just made aware that he had to beg for his account back after 5 week - again, the only reply towards my former director: Fuck you and your outdated thinking!). Btw. Thomas: I still know your Password 😈At first I thought I got lucky, nothing bad was going on with Thomas his account, I did the evil stuff via my account, and the sysadmins didn't understand what is going on until one of the sysadmins entered the evil command `whoami` and revealed that I was on a PC with some other account.

## The talk with the director

But the story didn’t finish here, I was sent to the school director, he was known to be one bad motherfucker with little sense of humor. Of course, I got yelled at, to wipe the stupid grin off my face and that I will be expelled from school and what was I thinking. I was leaving school anyway due to my lack of participation in class and my awesome grades. After which I got the reply “This is probably the best for all of us”

## 26 years later ...

Well, fast forward to today 26 years later. I work in IT, I worked for several years at a company as a developer and software tester and for over 10 years I’m running my own company. When you run a company you get some calls from time to time if you don’t want to sponsor something for a school and they give you space to put a logo and you can write off taxes as a donation and so on.

Weeeeeel, I got this very same call that the awesome school I was to be expelled from wants a donation. There was no relation to the fact that I went to that school, they just use a call center to call all or a lot of companies and try to find someone to donate. But hearing them ask for a donation from me ... I just had to laugh and passed on the offer.

But on second thought, if they would have let me put a screen playing this gif in a loop, I would have donated.

To all those teachers (not all of them!) who thought that I won’t make it in IT.... well guess what? I did, so fuck you!

<div style="width:100%;height:0;padding-bottom:77%;position:relative;"><iframe src="https://giphy.com/embed/I7p8K5EY9w9dC" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/futbol-I7p8K5EY9w9dC">via GIPHY</a></p>



