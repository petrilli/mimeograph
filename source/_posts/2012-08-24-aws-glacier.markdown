---
layout: post
title: "AWS Glacier speculation"
date: 2012-08-24 20:36
comments: true
categories: aws architecture
---

Let me preface this by say that I know absolutely _nothing_ about exactly what Amazon has done with their new [Glacier](http://aws.amazon.com/glacier/) service.In short, the product offers near-line storage of an unlimited amount of data for $0.01/gigabyte. Many people have looked at this and wondered what technology is backing it up, and while I don't have any inside information what-so-ever, I do have some knowledge around large-scale storage systems and how you would approach delivering this.

To begin, let's take a look at some of the assumptions we have to meet:

1. $0.01 per gigabyte per month
2. 99.999999999% durability, which is not to be confused with availability.
3. 3-5 hour typical retrieval times
4. "Unlimited" scalability

Let's get this out of the way: Amazon is _not using tape_. I can't provide any evidence for this, but various AWS people have publically made their distate for tape well known. So, with that assumption, I think we can safely say that they are based on traditional rotating hard drives.

The rest of this is going to be very speculative, but I think it likely fits into the general approach that AWS has taken. To analyze the entire system, we're going to talk about a couple of areas:

1. Data at rest costs
2. Power
3. Data ingest and retrieval
4. Bandwidth costs


## Data at rest costs

Since I've already said that Glacier is based on traditional rotating media, we need to decide what kind they're using. My guess would be 3TB SATA drives, as they currently represent the best capacity for your money. So how much is Amazon paying for these drives?  I would estimate that Amazon is paying less than $100 for a 3TB drive, perhaps even under $75. General retail is around [$150](http://www.newegg.com/Product/Product.aspx?Item=N82E16822148844), but Amazon has (conservatively) over 100PB of data in S3 currently, so they're buying power is excellent. 

Assuming that Amazon has an approximately 3x overhead for all storage -- including erasure coding and management administrivia -- that's upwards of 100,000 hard drives spinning in S3, but this is a very conservative estimate. Based on a $75 per-unit pricing, we're talking about $0.025 per gigabyte, and with a tripling for overhead that's $0.075 per gigabyte. 

Now, those drives have to live somewhere. While you could just pile them in the corner, they're harder to get data in and out of at that point. Instead, let's presume that Amazon has a custom storage server. It wouldn't be the [first company](http://blog.backblaze.com/2011/07/20/petabytes-on-a-budget-v2-0revealing-more-secrets/) to do such a thing. Since you don't need any redundant power supplies or anything in the system, let's assume they've got a box that 45 drives and costs them about $1,500 delivered. That gives you an amortized cost of $44.44 per drive in capital expense.

Put all that data together and we have a capital cost of $4,875 for 135TB of raw capacity, or 45TB of "usable capacity". That is $0.1083/gigabyte. Think about that. In less than 1yr of usage, AWS would recoupe all the costs associated with the storage itself, and it's easy to imagine a 7-10 year usable life for the hardware given some of the things that are discussed in the next section.


## Power

Forrester Research [estimates](http://www.cio.com/article/627363/Forrester_3_More_Ways_to_Cut_Data_Center_Energy_Costs) that the cost of power will exceed the capital cost of servers over their useful life. Do you know how you fix that problem? 

_Turn them off._

The key is the 3-5 hour retrieval time that AWS quotes.  I'll go into it more, but it's key to being able to turn the servers off as often as possible. The overall goal is to turn a server on, fill up all it's hard drives and then turn it back off for as long as possible.  In fact, you could spin hard drives up and down as needed, saving even more space.  You're basically treating them as "tape" by filling them up sequentially (approximately).

A powered off server uses almost no power. There's a tiny bit for the baseband controller that you need to remotely turn it on, but that's nothing compared to spinning up the hard drives.

One additional area AWS may be benefitting from is that as such a huge hard drive purchaser, they might be able to get custom motors or at least firmware that allow the hard drive to spin slower and use less power.  Because of the totally different performance characteristics, a hard drive running at 5,400 RPM, or even 3,600 RPM, is likely to be plenty fast enough for the application.

Note that this also likely has something to do with the odd [penalty for early deletion](http://aws.amazon.com/glacier/faqs/#How_am_I_charged_for_deleting_data_that_is_less_than_3_months_old).  That means they have to keep the server spun up to refill the deleted data.

If you can turn the server off, that means it's not generating heat. That means you can use less A/C, which is a huge capital and expense item for a data center. Finally, if you were to build dedicated parts of a data center to just hold Glacier components, then you can run the whole thing at a higher temperature because you only have a small number of servers running concurrently and the remaining air becomes a bit of a heat sink allowing it to absorb the BTUs.  

Finally, hard drives have a certain number of hours they're rated for, but as Google [discovered](http://research.google.com/pubs/pub32774.html), there's a lot of interesting failure issues involved.  Hard drives that aren't spinning last long, though of course there are limits even to this.  Eventually, they'll fail, but the wear-and-tear is much lower.


## Data ingest and retrieval

So how does data get into Glacier? Dollars to donuts says that you don't talk directly to Glacier. I would imagine there's a bit of hierarchical storage going on, with S3 being used as a staging repository. Put simply, data is uploading by customers to Glacier through a front end that stores it in S3 until enough data has accumulated to justify spinning up a new set of servers and filling them with data. Once that's done, the data can be aged out of the S3 "cache".  

When you ask for a retrieval, however, I suspect there's a coalescing of requests to make sure that as many requests from the same set of machines as possible is satisfied at once. This, combined with the power discussed earlier, is why there's a 3-5 hour lag, and maybe longer. It also is a psychological pressure not to treat Glacier as a cheap version of S3, but instead as a true "cold storage".  Once retrieved, the data is staged into S3 and available for download.

My guess is that the future capability to do aging in and out of S3 is linked in this. Most likely, AWS is just working out the bugs in their own use before making it generally available.


## Bandwidth costs

When you buy large amounts of bandwidth, you're generally buying symmetrical bandwidth. Buy 100Gbps and you actually are talking 200Gbps, with 100 in each direction. I have no actual data for AWS, but in my experience, most hosting providers have more egress data than ingress. I'm sure there's exceptions, but that's generally the case. This is part of why AWS can offer ingress bandwidth for free. For them, it likely is something approaching free, because it's already provisioned and sitting idle. Also, every gigabyte you upload costs you money to store.


## Conclusion

So there you have it.  No miracles, just the intelligent application of a lot of holistic system tuning for a specific workload.  Now some have supposed that this is just a layer on top of S3, but I think that's likely not true just because of the totally different workload impacts.  What I suspect is it's derived from S3 code wise, but doesn't share the same infrastructure in anyway.
