---
author: Cristian Livadaru
title: "Sweet Titles by class"
date: 2007-02-27
url: /2007/02/27/sweet-titles-by-class/
slug: sweet-titles-by-class
categories:
  - tech
draft: false
---
#

I am working on the new version of the SMS Central which will be integrated in Joomla, it quite takes some time since I don’t have internet at home and it’s more a trial and error process. This is when you notice how much one is used to the internet and google. But at least I have MAMP (Apache PHP MySql) for Mac and I can at least do some tests. I came across Sweet Titles, which is great, but by default it does the “Sweet Titles” for the complete site, which isn’t really nice on a joomla site. The simplest solution is to use getEelementById to do it only for one id, this again is also not what I want, because a ID has to be unique, and I want it on more then one place. My solution was to use a GetElementsByClass function which I found here, and modify the original sweettitle.js.

Original:

```js

init : function() {
if ( !document.getElementById ||
!document.createElement ||
!document.getElementsByTagName ) {
return;
}
var i,j;
this.tip = document.createElement(‘div’);
this.tip.id = ‘toolTip’;
document.getElementsByTagName(‘body’)[0].appendChild(this.tip);
this.tip.style.top = ’0′;
this.tip.style.visibility = ‘hidden’;
var tipLen = this.tipElements.length;
for ( i=0; i
```
