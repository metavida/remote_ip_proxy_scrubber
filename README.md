[![Build Status](https://travis-ci.org/metavida/remote_ip_proxy_scrubber.svg?branch=master)](https://travis-ci.org/metavida/remote_ip_proxy_scrubber)
[![Code Climate](https://codeclimate.com/github/metavida/remote_ip_proxy_scrubber/badges/gpa.svg)](https://codeclimate.com/github/metavida/remote_ip_proxy_scrubber)
[![Test Coverage](https://codeclimate.com/github/metavida/remote_ip_proxy_scrubber/badges/coverage.svg)](https://codeclimate.com/github/metavida/remote_ip_proxy_scrubber)

# remote_ip Proxy Scrubber

A project that makes it as easy as possible to prevent Rails from logging IP addresses that belong to proxy devices in your HTTP request chain.

Because Rails has pretty dramatically changed how these sorts of IPs are filtered over the years, this project's ultimate goal is to make life easy on as many Rails versions as possible.

# Common Use-cases

* Using [CloudFlare in front of your app](https://www.cloudflare.com/ips)
* Using [Incapsula in front of your app](https://incapsula.zendesk.com/hc/en-us/articles/200627570-Restricting-direct-access-to-your-website-Incapsula-s-IP-addresses-)

# Usage

Let's say you've got proxy servers running outside of the local network where your Rails app is running. In this example, we'll say the IP addresses of these proxy servers are in these IP ranges: `17.0.0.4/30`, `17.17.0.8/30`

## Fixing `request.remote_ip`

Without this gem, calls to `request.remote_ip` from your Rails app will return the IP addresses from your proxy servers. Adding the code, below, ensures that `request.remote_ip` will never return the IP addresses of your proxy servers, and assuming the servers that first process requests from your clients is adding an appropriate X-Forwarded-For header, `request.remote_ip` will return the real IP address of your clients!

```ruby
# Add the following to config/application.rb or conifg/environments/*.rb

config.action_dispatch.trusted_proxies = RemoteIpProxyScrubber.config([
  "17.0.0.4/30",
  "17.17.0.8/30",
])
```

## Fixing Rails logs

**Oddly enough**, even with `request.remote_ip` returning the correct value, Rails log will *still* contain IP addresses from your proxy servers. To fix this, you'll need to tell Rails to use a different logger.

```ruby
# Add the following to config/application.rb or conifg/environments/*.rb

config.middleware.insert_before(Rails::Rack::Logger, RemoteIpProxyScrubber.patched_logger)
config.middleware.delete(Rails::Rack::Logger)
```

# Questions? Contributions?

If this gem isn't working for you, feel free to open up an Issue, or a Pull Request if you've got a proposed solution! I maintain this project in my spare time, so your patience is appreciated.

# Credit

Thanks to [Haiku Learning](http://www.haikulearning.com) for sponsoring the initial development of this gem. We're scratching our own itch, but hopefully it's helpful for you too!