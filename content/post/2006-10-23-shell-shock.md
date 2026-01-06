---
author: Cristian Livadaru
title: "Shell Shock :)"
date: 2006-10-23
url: /2006/10/23/shell-shock/
slug: shell-shock
categories:
  - tech
draft: false
---
#

[One Week Back to Windows – OSNews.com][1]

 [1]: http://www.osnews.com/story.php/16260/One-Week-Back-to-Windows/page4/

> One of the things that has always made Unices so popular and admired was the shells out there. In fact, most operating systems today have some sort of a competent CLI interface. This is for two reasons. Firstly, in order to offer a way to automate repetitive tasks. Secondly, because you may expect to login remotely, without having access to a graphical environment. And thirdly, because there are cases when you will simply discard the GUI, like when running a web server.
>
> Windows sticked to cmd.exe, which is essentially a slightly polished version of command.com. Command.com itself is little more than a CP/M shell clone. So essentially, cmd.exe offers the same facilities which computers were offering **25 years ago**, on Z80-based machines. Needless to say, this is very painful



Oh yes how true. I now have to search for some software that can change the size of some images in batch and also watermark them. Since ImageMagik is available for windows it would be quite easy if windows had some usefull shell, but how do you do this on windows?

    for ii in *.jpg
    do
      convert -resize 600x600 $ii $ii
    done
