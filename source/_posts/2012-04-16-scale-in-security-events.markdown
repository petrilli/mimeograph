---
layout: post
title: "Scale in Security Events"
date: 2012-04-16 20:41
comments: true
categories: security seim big-data
---

The other day, I was having a discussion with a developer about scaling systems to process security events. Now, let me preface this by saying that I used to work for one of the pioneering companies and have a pretty good understanding of what it takes to scale a {% abbr SEIM "Security and Information Management" %} solution, although back then, we just called them {% abbr SIM "Security Information Management" %}. This engineer was talking about how they were handling "millions of events per day". How many millions, I asked? "Well, we handle over four million for our internal systems."

"Four million" sounds really impressive, doesn't it? That's a lot of data, and I won't deny that, but it's not *that much* data when it comes down to it. For capacity planning, if all I had was a daily rate, I took that rate over 12 hours to compensate a bit for what is termed the [peak busy hour](http://en.wikipedia.org/wiki/Busy_hour). It's not an elegant solution, but it solves the back-of-the-napkin estimate world just fine. So, 4M/day is about 93 events per second.

On the surface, that seems like a lot, but it's not. Even when I was immersed in the SEIM world on a day-to-day basis, we were dealing with many customers who were attempting to digest 10,000 {% abbr EPS "Events per Second" %}. That translates to approximately 432,000,000 events per day, or several orders of magnitude greater. Mind you, that was in the early 2000s, and the world has gotten a lot more intense than it was back then. I know of organizations dealing with 100,000 EPS, or more, today.

Now, if we assume the average security event is (uncompressed) approximately 64 bytes, once some normalization happens, then you're talking about 6.25 megabytes per second of data to deal with. It's a lot, and 99.999% of it is useless when it arrives. It only becomes interesting later, but you won't know how far in the future that will be.

To put it all in perspective, if you could print a single event on a single line on a sheet of paper, and assuming you can print 66 lines on a page (something we used to do in the days of line printers), then that's 151 pages *per second* in my old experiences, and over 1,515 pages today. Every second. Stick that in your shredder and think about it.

So, that brings me to my point: before you go around bragging about performance, it's best to understand what state-of-the-art really is. Big data arrived a very long time ago in the security world, but the tools and technologies still haven't caught up.