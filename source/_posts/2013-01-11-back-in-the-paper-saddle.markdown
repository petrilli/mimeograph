---
layout: post
title: "Back in the paper saddle"
date: 2013-01-11 23:17
comments: true
categories: reading-list
---

Ever since I was in college, and would sneak into the AI department's area to grab copies of their papers and technical reports, I've been a voracious reader of academic research.
Too often in the "go go go" commercial world, we lose our perspective of work that is being done, and especially of the many decades of research upon which all our toys are built.
That's not to say that there aren't plenty of papers and such from Google, Amazon, et. al., but I actually include many of those in the same academic realm as I would something from Stanford or MIT.

Anyway, for various reasons too tedious to go into, I've allowed my inbox (also known as [Dropbox](http://dropbox.com/)) to accumulate over a hundred papers that I intended to read, but haven't found time to yet.
That doesn't begin to include all the amazing blog articles, etc., that accumulate in [Instapaper](http://instapaper.com) at all times.
The Internet may be an amazing thing, but it also is a source of unlimited future reading.
So, starting this year, and today to be exact, I've decided to try and put time aside every day to read a few of the things I've accumulated and try and slowly work down my backlog.
I was asked by a friend on Twitter to keep track of what I'm reading, and so, this is the start.

* <cite>Hancock: A language for analyzing transactional data streams</cite> 
([CiteSeerX](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.91.3721)). 
A DSL for performing some relatively basic stream processing on large amounts of "sensor data", in this case primarily telephone calls. 
Interesting ideas: 
1) persistence mechanism that mirrors UNIX sensabilities with directories as containers; 
2) view representation for abstracting data requirements over time, namely exact versus approximate representations
* <cite>Crash-only Software</cite>
([CiteSeerX](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.3.9953)).
What if we just gave up and quit trying to recover from errors? 
Sometimes it's faster to just crash the system and reboot.
Came with a couple interesting papers I want to read, namely <cite>[Decoupled storage: Free the replicas!](https://www.usenix.org/conference/usits-03/decoupled-storage-free-replicas)</cite> and <cite>[Session State: Beyond Soft State](http://research.microsoft.com/apps/pubs/default.aspx?id=74713)</cite>
* <cite>PASSing the provenance challenge</cite>
([Harvard](http://www.eecs.harvard.edu/~syrah/node/201)).
Integrating [data provenance](http://en.wikipedia.org/wiki/Provenance#Data_provenance) into the Linux operating system.
* <cite>CryptDB: Protecting Confidentiality with Encrpyted Query Processing</cite>
([CiteSeerX](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.226.1498)).
A new approach to encryption in the database that seems very different than anything I've seen in the commercial sector yet.
One of the things I like is that it is adaptive and blends different approaches to encryption -- including [homomorphic encryption](http://en.wikipedia.org/wiki/Homomorphic_encryption) where appropriate -- to obtain maximum functionality with minimized risk.
Definiately want to look at this to play with, and it seems to currently work with MySQL and PostgreSQL with varying degrees.

A final note, and something that continues to amaze me in 2012: if your paper is not available *for free* to read, then why are you publishing your paper? 
I continually run into annoying pay walls -- ACM and IEEE, I'm looking at you -- that do nothing but impede research and progress.
Now, usually you can Google around and find the paper hosted somewhere, but if you are an academic and your profession is (supposedly) about the progress of human knowledge, how can you subscribe to this kind of walling off of knowledge?
