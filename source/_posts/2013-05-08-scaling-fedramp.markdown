---
layout: post
title: "Scaling FedRAMP"
date: 2013-05-08 08:45
comments: true
categories: security fedramp cloud
---

[FedRAMP](http://www.fedramp.gov/) was created to provide "a standardized approach to security assessment, authorization, and continuous monitoring for cloud products and services.".
To an outsider, this sounds like a whole bunch of nonsense, but if you've ever had to deal with the [NIST Risk Management Framework](http://csrc.nist.gov/groups/SMA/fisma/Risk-Management-Framework/), at least as it is always implemented by government agencies, you'll understand how absolutely critical it is that the approach be standardized.
As a geek, nerd, and overall general enemy of paperwork, I have to start by simply saying that conceptually, I don't have a problem with the Risk Management Framework (RMF).
If you sit down and talk to Dr. Ross, the man behind the curtain, you'll see that he's generally a very reasonable person, and his goals are simply to provide a conceptual framework for the Federal government to understand and assess the risk of its systems.

The reality, unfortunately, is much darker.
Instead of using the RMF, and its [accompanying standards](http://csrc.nist.gov/publications/PubsSPs.html) as the framework they are intended to be, they are instead generally treated as a veritable gospel that can never be questioned, thought about, reasoned about, or otherwise adapted to the situation at hand.
This creates a situation that inverts the incentives and often creates systems that have much lower actual security, and substantially increased risk, but have lots of paperwork to get the approval.

Now that I've taken some organizations through the FedRAMP process, I can say that it is an improvement.
It is more risk-focused, and more interested in being a collaborative effort to actually identify risk and address them wherever possible. 
It still suffers from a serious paperwork overhead, however, and worse, there are some conceptual gaps within it that do not address the neads of large cloud providers.
I'm going to try and address some of the ideas that I think need to be tackled within FedRAMP to succeed with the likes of Amazon, Windows Azure, Google, Rackspace, etc.
Without these changes, or something more effective even, I believe that FedRAMP, for all its admirable goals, will wither and die.

In follow-on articles, I'm going to cover some ideas for how to scale FedRAMP to both larger and, where I can, smaller cloud service providers.
Most of my experience is with the gorillas in the yard, so it will focus on that, but I'd like to see it made more flexible for the organizations just starting, especially when they're in the SaaS/PaaS space.

The topics I intend to cover are:

* Issues of technical scale -- How do you scale FedRAMP to deal with the issues faced by the likes of Amazon, Google, Microsoft, Rackspace, et. al.? 
* DevOps v. The Paperwork Monster -- Specifically how do you deal with the enormous velocity exhibited by most cloud providers?  The RMF isn't really used to coping with this rate of change. No calculus, I promise.
* Importance of automation -- Spot checks of technical controls are fine, but the key is all inside the automation, which is rarely covered by many 3PAO.

If anyone has any other ideas they'd like to see addressed, I'd be happy to delve into them.  Just as a note for my qualifications, I'm the quality manager for a major 3PAO, and technical lead on large-scale cloud projects.
