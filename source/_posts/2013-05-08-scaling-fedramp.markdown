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


## Understand Scale

## DevOps

## Focus on Automation

## Define Significant Change

### The Problem

As part of the [continuous monitoring strategy](http://www.gsa.gov/graphics/staffoffices/Continuous_Monitoring_Strategy_Guide_072712.pdf) and the individual cloud provider's configuration management plan, the cloud provider must notify FedRAMP of any "significant change to the system".
What is a significant change, you might ask?
Well, according to the only list that is available currently, the following changes would constitute significant changes:

1. Authentication or access control implementation;
2. Storage implementation;
3. Adding IP address to your inventory;
4. New code release;
5. A COTS product implemented in your system is changed to a completely different product;
6. Backup mechanisms and process;
7. PaaS or IaaS changing IaaS provider;
8. New interconnections to outside service providers;
9. Changing alternate (or compensating) control
10. Removing security control;
11. "Other"

Obviously, some of these are clearly things that have impact on the security posture of the system, such as changing authentication implementations.
Otherwise, such as numbers 3, 4, and 8, are in many cases common place. 
How many times _daily_ does Amazon add IP addresses to their inventory? 
How often do cloud providers, who often operate within a DevOps model, release new code?
And why would new connections to ISP/NSP need to be discussed with the JAB?

One big issue is that for many of the major players, revealing some of this information would be considered a _serious_ breach of security, and potentially impact their position in the market.
Wouldn't you like to know how many servers Google added last week? 


### Some Ideas

There are a couple of ways to make this a more managable and scalable process.
First, it's necessary to identify the kind of activities that are common daily/weekly/monthly things, such as adding additional storage capacity, expanding compute infrastructure, rolling out bug/performance fixes to code, etc., which represent a standard process.
These processes can be reviewed during the initial assessment, and so long as they're being followed, then they should _never_ constitute a "signficant change" to the system. 
Can you imagine what would happen if Amazon, or Google, were required to submit a form every time they added a server? 

Second, the security impact assessment process should be looped in as a lightweight process.
It could be something as simple as an additional field in a ticketing system that's used to track changes. 
The summary of those changes could be submitted on some periodic basis (monthly?) to the 3PAO for assessment to ensure that the cloud provider is meeting their end of the FedRAMP bargain.
Anything outside the normal bounds would then be reported to the JAB, but the noise level would be kept to a minimum, and only items which actually had a material impact on the security posture and risk profile of a system would need to be addressed.
