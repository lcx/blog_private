---
author: Cristian Livadaru
categories:
- tech
tags:
- rails
title: "Rails Pdf Templates"
slug: rails-pdf-templates
date: 2022-09-06T16:38:13+02:00
summary: PDF in Ruby can be done very simple with Prawn PDF and it comes with
  lots of documentation, examples and features. The problem starts when you
  want to offer users the posibility to modify the look of the PDF but still
  have the posibility to fill in data from the application. This is where
  Thinreports comes to the rescue.
draft: true
---

## PDF in Ruby
PDF in Ruby can be done very simple with Prawn PDF and it comes with
lots of documentation, examples and features. The problem starts when you
want to offer users the posibility to modify the look of the PDF but still
have the posibility to fill in data from the application. This is where
Thinreports comes to the rescue.

### Thinreports

The idea behind [Thinreports](https://github.com/thinreports/thinreports) is
that you can give it a template file, which is just a json file, that contains
the look and layout of the pdf and which fields in the PDF are updateable from
within the application.
Thinreports consists of two parts, one is the Thinreport used in the rails/ruby
code and the other one is the [Thinreports Generator](https://github.com/thinreports/thinreports-generator)
which allows the user to modify the looks of the PDF.


