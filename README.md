# remote_ip Proxy Scrubber

A project that makes it as easy as possible to prevent Rails from logging IP addresses that belong to proxy devices in your HTTP request chain.

Because Rails has pretty dramatically changed how these sorts of IPs are filtered over the years, this project's ultimate goal is to make life easy on as many Rails versions as possible.