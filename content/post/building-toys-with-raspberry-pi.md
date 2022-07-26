---
author: Cristian Livadaru
categories:
- raspberry
- kids
date: "2019-09-20T10:21:08Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1508175800969-525c72a047dd?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=2000&fit=max&ixid=eyJhcHBfaWQiOjExNzczfQ
slug: building-toys-with-raspberry-pi
summary: Trying to come up with something useful build on a raspberry to teach my
  daughter about tech and coding.
tags:
- raspberry
- kids
title: Building toys with raspberry PI
---


I always wanted to build something cool and fun for my daughter (6 years old) with a raspberry pi but didn't really have an idea where to start until one day she was in my office, I had the raspberry on my desk with a sense hat but it was not plugged in and she asked me what this is so I plugged in the Raspberry and the Sense hat lit up and filled the screen with a rainbow.

{{< figure src="/images/2019/09/raspberry-sense-hat.jpg" caption="Raspberry Sense hat" >}}

<iframe src="https://giphy.com/embed/Nm8ZPAGOwZUQM" width="480" height="454" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/reaction-Nm8ZPAGOwZUQM">via GIPHY</a></p>

This led me to my first idea of what to build for the raspberry to get my daughter interested. Enable her to write some text and send it to the raspberry's sense hat display!

## Writing things to the sense hat

This is a very simple script assembled for the sense hat howto and some stackoverflow input, didn't really write anything in python so far but it works for demo purposes.

```python
# -*- coding: utf-8 -*-

from sense_hat import SenseHat
import random

sense = SenseHat()

sense.set_rotation(180)
red = (255, 0, 0)
green = (0, 255, 0)
blue = (0, 0, 255)

while True:
  rand = random.randint(0,9)
  if rand >= 0:
    color = red
  if rand >= 4:
    color = green
  if rand >= 7:
    color = blue

  f = open("demofile.txt", "r")
  text = f.read()
  f.close
  message = text
  print("printing text: " + text)
  # Display the scrolling message
  sense.show_message(message, text_colour=color, scroll_speed=0.10)
```

It just reads the content of a file and sends it to the display, before doing that it gets some random value to pick a color of the text.

What we need now is some way to get a text value into this `demofile.txt` for the python script to send it to the sense hat.

## The "web interface"

Ok calling this small [sinatra](http://sinatrarb.com/) script a web interface is a bit overkill.

```ruby
require 'sinatra'
set :bind, '0.0.0.0'
set :port, 80

get '/' do
  erb :index
end

post '/print' do
  `echo #{params['text']} > demofile.txt`
  redirect '/'
end
```

since I will be running this script as root (yeah I know ...) I want to bind it to port 80 and it must of course bind to `0.0.0.0` otherwise we won't reach it from outside. Now what's left is the view.

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Print to Display</title>
  </head>
  <body>
    <h1>Print text to Display</h1>
    <p>What should we print now?</p>
    <form action="/print" method="post">
      Text: <input type="text" name="text"><br>
      <input type="submit" value="Submit">
    </form>
  </body>
</html>

```

This masterpiece now is the view for this little project.

Here's how it works, if you run the python script it will loop infinitely, read the content of the text file and send the content to the display. The sinatra app will give you an input field. If submitted it will dump the content into the text file which will be read by the python script and sent to the display.

**Be aware that running this as root and dumping things via system call is very dangerous.**

## Starting everything

Now in order to start it on boot, create this little shell script and add it to cron like this `@reboot /root/sense_hat/start.sh` 

```bash
#!/bin/bash
cd /root/sense_hat
nohup ruby app.rb &

while :
do
  cd /root/sense_hat
  python3 clear.py
  echo "Ready! `ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`" > demofile.txt
  python3 print_text.py
done

```

it should at startup print the IP it got, but in my first tests it was blank, might be due to the fact that the script started before the raspberry managed to pull an IP from the DHCP Server.

Now boot up the raspberry and have fun!

{{< figure src="/images/2019/09/raspberry-sense-hat-text-scroll.jpg" caption="Scrolling text on the sense hat" >}}



