---
layout: post
title: "Secure Linux Instances in the Cloud"
date: 2012-04-16 14:56
comments: true
categories: security linux network
---

In the security world, we talk about [defense in depth](http://www.nsa.gov/ia/_files/support/defenseindepth.pdf) (PDF), which basically means that your castle should have a moat, a drawbridge, a lock, and a lot of archers on the ramparts. Historically, in the computer security world this meant that you would have firewalls, {% abbr IDS "Intrusion Detection System" %}, and a multitude of different layers of security. Unfortunately, a lot of that is no longer applicable when you deploy applications into "the cloud". Instead, you have to rethink what those defenses are and how they reinforce and support one another.

The first layer of defense you have control over is what packets end up at your systems, and what you do with them. For a Linux machine, this is controlled by the [iptables](http://www.netfilter.org/projects/iptables/index.html) component of the operating systems. The goal of this moat around your system is to try and keep a vast majority of the stupid at bay. There's lots of things that you should never, ever, see, and that there's simply no reason to even bother with.

What I'm going to do is walk you through the foundation rule set (my starter moat) that I base everything else on, which you can find as a [gist on GitHub](https://gist.github.com/1959001). Please feel free to use however you wish, though if you find a mistake I would ask you just let me know by putting a comment on the gist itself. Feel free to add your own alligators and flaming spikes.


Categorizing Flows
------------------

The first thing we need to do is group our traffic into different chains of rules that will be applied.  This makes it a bit easier to deal with. Note that the [gist](https://gist.github.com/1959001) has a lot of this as comments.

	-N ICMP_IN
	-N ICMP_OUT
	-N SPOOF_LOG_DROP
	-N SPOOF_IN
	-N SPOOF_OUT
	-N BAD_TCP_FLAGS

The first two, `ICMP_IN` and `ICMP_OUT` are somewhat self explanetory.  We want to treat all {% abbr ICMP "Internet Control Messaging Protocol" %} carefully. The next three, `SPOOF_LOG_DROP`, `SPOOF_IN` and `SPOOF_OUT` are all about address spoofing protection, something everyone *should* be doing, but usually isn't. The last one, `BAD_TCP_FLAGS` is looking for all sorts of nasty behavior that people use for either OS detection, or often to try and find exploits in a system.

We'll be going through them in roughly that order.


ICMP Management
---------------

	-A ICMP_IN -p icmp --icmp-type 8 -j DROP
	-A ICMP_IN -p icmp -i eth0 --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT
	-A ICMP_IN -p icmp -i eth0 --icmp-type 3 -m state --state ESTABLISHED,RELATED -j ACCEPT
	-A ICMP_IN -p icmp -i eth0 --icmp-type 11 -m state --state ESTABLISHED,RELATED -j ACCEPT
	-A ICMP_IN -p icmp -i eth0 -j DROP
	-A ICMP_OUT -p icmp -o eth0 --icmp-type 8 -m state --state NEW -j ACCEPT
	-A ICMP_OUT -p icmp -o eth0 -j DROP
	-A INPUT -p icmp -j ICMP_IN
	-A OUTPUT -p icmp -j ICMP_OUT

In line 1, we just ignore all the ICMP echo requests (type 8). Ping is a good example of a use of an echo request. There's just no reason to respond to them normally. If, however, you have a tool that needs to ping your system to get a response, then you'll need to modify the filter slightly to be address-specific.  Line 2 drops anything that's an echo response (type 0) which we didn't initiate. Next, lines 3 and 4 drop the destination unreachable (type 3) and {% abbr TTL Time to Live %} (type 11) responses if they're not related to something we sent. These are another sneaky way to peek into a system. 

Then, we drop everything else, because they fail the sanity check. Generally, a system would only send an echo request in response to a ping command, and there's only three responses that make any sense to those in the modern world: response, TTL-exceeded and destination unreachable.


Spoofed Packets
---------------

Now that we've dealt with incoming packets, we're going to allow echo requests (ping) to leave the system. Everything else ICMP-related, such as redirects, timestamp requests, etc., shouldn't be coming or going, and so we drop them without note. Finally, we attach our rule chains to the core rule chains, `INPUT` and `OUTPUT`.

	-A SPOOF_LOG_DROP -j LOG --log-prefix "IPT: spoofed "
	-A SPOOF_LOG_DROP -j DROP
	-A SPOOF_IN -i eth0 -s <MYIP> -j SPOOF_LOG_DROP

With ICMP traffic out of the way, we need to deal with traffic coming and going to addresses that don't pass the sanity check. You can find a lot of these addresses in [RFC3330](http://tools.ietf.org/html/rfc3330), "Special-Use IPv4 Addresses". People often forget there's more out there than just the addresses in [RFC1918](http://tools.ietf.org/html/rfc1918). So, since we want to keep an eye on this, the first thing we do (lines 1-2) is set up some log configuration. Log messages matching this rule chain will be prefixed with "IPT: spoofed". IPT just stands for IP tables.

So, before we go any further, we need to make sure nobody is spoofing our own addresses. In line 3, you'll see something `<MYIP>`, which needs to be replaced by whatever IP address is used by the host. The rule says "if I see something with a source address that is mine on my ethernet connection, drop it". You shouldn't see it showing up there. Ever. If you do, you likely either have a serious security problem, or need to talk to someone about how networking is set up in detail.
	
	-A SPOOF_IN -i eth0 -s 10.0.0.0/8 -j SPOOF_LOG_DROP
	-A SPOOF_IN -i eth0 -s 172.16.0.0/12 -j SPOOF_LOG_DROP
	-A SPOOF_IN -i eth0 -s 192.168.0.0/16 -j SPOOF_LOG_DROP

Next, we block all the standard RFC1918 addresses. Now, if you're actually using them internally, you can't do this, but this is from situations where my server only has a publicly routable address. 

	-A SPOOF_IN -i eth0 -s 198.18.0.0/15 -j SPOOF_LOG_DROP
	-A SPOOF_IN -i eth0 -s 169.254.0.0/16 -j SPOOF_LOG_DROP
	-A SPOOF_IN -i eth0 -s 192.0.2.0/24 -j SPOOF_LOG_DROP

Here, we block (line 1) the official "benchmarking" networks, defined in [RFC2544](http://tools.ietf.org/html/rfc2544). While I've yet to see them in the wild, they shouldn't show up, and part of the goal of this rule set is to make sure we set a sanity benchmark.
Next, line 2 drops link local traffic ([RFC3927](http://tools.ietf.org/html/rfc3927)).  Link local addresses are those that are "randomly" assigned when an interface doesn't have a static address, and can't use something like {% abbr DHCP "Dynamic Host Configuration Protocol" %} to dynamically assign one. Again, it should never show up in a "normal" situation.  Line 3 drops TEST-NET traffic. TEST-NET, as defined in [RFC5737](http://tools.ietf.org/html/rfc5737) is intended only for use in documentation. Once again, it should *never* show up in production use.

	-A SPOOF_IN -i eth0 -s 224.0.0.0/4 -j SPOOF_LOG_DROP
	-A SPOOF_IN -i eth0 -s 240.0.0.0/4 -j SPOOF_LOG_DROP

Since I almost never have any use for [multicast](http://en.wikipedia.org/wiki/Multicast), I drop everything associated with the standard multicast blocks, defined in [RFC5771](http://tools.ietf.org/html/rfc5771).

	-A SPOOF_IN -i eth0 -s 127.0.0.0/8 -j SPOOF_LOG_DROP
	-A SPOOF_IN -i eth0 -s 0.0.0.0/8 -j SPOOF_LOG_DROP
	-A SPOOF_IN -i eth0 -s 255.255.255.255/32 -j SPOOF_LOG_DROP

Now, we also shouldn't see loopback addresses, or other bonkers addresses showing up on our Ethernet interface. See below for information on the loopback protections.

	-A SPOOF_OUT -i eth0 -s ! <MYIP> -j SPOOF_LOG_DROP

One thing many people forget to do is block their systems from becoming a source of problems. So, we block any outgoing traffic on our Ethernet interface that isn't originating from my IP address.

	-A INPUT -j SPOOF_IN
	-A OUTPUT -j SPOOF_OUT

And now, finally, we attach these new rule chains to the primary ones, just a we did before.


TCP Flags
---------

That brings us to the last "protection" set of rules: those associated with all sorts of crazy flags in the TCP packet. If you've forgotten, the TCP packet has 9 potential flags. Read {% abbr LSB "Least Significant Bit" %} to {% abbr MSB "Most Significant Bit" %}:

* NS: {% abbr ECN "Explicit Congestion Notification" %}-nonce concealment protection ([RFC3540](http://tools.ietf.org/html/rfc3540))
* CWR: Congestion Window Reduced flag is set by the sender to indicate that it received a TCP segment with the ECE flag and had responded in congestion control mechanism ([RFC3168](http://tools.ietf.org/html/rfc3168))
* ECE: ECN-Echo indicates:
  * If SYN flag is set, that the TCP peer is ECN capable.
  * If SYN flag is clear, that a packet with Congestion Experienced flag in IP header set is received during normal transmission (RFC3168).
* URG: the Urgent pointer field is significant
* ACK: the Acknowledgment field is significant. All packets after the initial SYN packet sent by the client should have this flag set.
* PSH: Push function. Asks to push the buffered data to the receiving application.
* RST: Reset the connection
* SYN: Synchronize sequence numbers. Only the first packet sent from each end should have this flag set.
* FIN: Finished. No more data from sender

Only some of these can be set "together", and often you find people probing systems to see how they respond to various flag combinations. For example, one of the techniques for OS detection used by [nmap](http://nmap.org) is to play with the various flags to see how a host responds.  We don't use the SPOOF_LOG_DROP-style reaction because we want to change the log message so we know what's going on.

	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOG --log-prefix "IPT: Bad SF flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,RST SYN,RST -j LOG --log-prefix "IPT: Bad SR flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN,PSH SYN,FIN,PSH -j LOG --log-prefix "IPT: Bad SFP flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN,PSH SYN,FIN,PSH -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN,RST SYN,FIN,RST -j LOG --log-prefix "IPT: Bad SFR flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN,RST SYN,FIN,RST -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN,RST,PSH SYN,FIN,RST,PSH -j LOG --log-prefix "IPT: Bad SFRP flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags SYN,FIN,RST,PSH SYN,FIN,RST,PSH -j DROP

But sometimes, we need things set together, and if they aren't, then it doesn't make sense from a network stack perspective. Then, we have some things that can not exist in the first SYN packet, so they must be accompanied by the ACK flag. If they're not, we don't want them.

	-A BAD_TCP_FLAGS -p tcp --tcp-flags ACK,FIN FIN -j LOG --log-prefix "IPT: Bad F-A flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ACK,FIN FIN -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ACK,PSH PSH -j LOG --log-prefix "IPT: Bad P-A flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ACK,PSH PSH -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ACK,URG URG -j LOG --log-prefix "IPT: Bad U-A flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ACK,URG URG -j DROP

Then, we have people who think it's OK to have no flags or all the flags set:

	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL NONE -j LOG --log-prefix "IPT: Null flag "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL NONE -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL ALL -j LOG --log-prefix "IPT: All flags "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL ALL -j DROP

Oh, and [merry Christmas](http://en.wikipedia.org/wiki/Christmas_tree_packet). Normally, I'm all for Christmas, but, these are just insane:

	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL FIN,URG,PSH -j LOG --log-prefix "IPT: Xmas flags "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j LOG --log-prefix "IPT: Merry Xmas flags "
	-A BAD_TCP_FLAGS -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

And then, just attach it to the main `INPUT` rule chain.

	-A INPUT -p tcp -j BAD_TCP_FLAGS


Normal Traffic Controls
-----------------------

Now we get into more "normal" traffic controls.  First, we want to allow everything on the loopback (lo) interface. This is used for both local servers (such as databases, proxies, etc.) and for SSH tunneling:

	-A INPUT -i lo -j ACCEPT

And drop it if it is on the loopback network, but not coming through that interface:

	-A INPUT -i ! lo -d 127.0.0.0/8 -j REJECT

We also want to allow all traffic associated with previously permitted connections. These are generally called "established" connections:

	-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

Now, it might be helpful if we allow traffic to originate from the system to other places.  On some systems, I also tighten this down to be only a very small subset of traffic, perhaps only HTTP, but that's the next step, and this is the 81% rule.

	-A OUTPUT -j ACCEPT

And that brings us to inbound application traffic. This is traffic we expect to be coming in, such as web browser traffic to a web server, or SSH:

	-A INPUT -p tcp --dport 80 -j ACCEPT
	-A INPUT -p tcp --dport 443 -j ACCEPT
	-A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

Now we need to tweak some of the logging information. We don't want to get overwhelmed with logs and have that turn into a denial-of-service attack itself.  So, to prevent that, we restrict it to bursts and 60/minute:

	-A INPUT -m limit --limit-burst 100 --limit 60/min -j LOG --log-prefix "IPT: denied " --log-level 7

Repeat after me: that which is not explicitly permitted is denied:

	-A INPUT -j REJECT

Also, forwarding is evil. Do not forward on this host. Ever.

	-A FORWARD -j REJECT

And that's the basic set of rules.  You can customize these till your heart's content, but this is a start. Sadly, it won't be all the security you need, but it's better than what many people have sitting out there.