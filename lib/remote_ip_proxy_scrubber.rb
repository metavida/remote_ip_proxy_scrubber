$:.unshift File.dirname(__FILE__)

require 'remote_ip_proxy_scrubber/version'
require 'remote_ip_proxy_scrubber/ip_list'

module RemoteIpProxyScrubber
  # Add the following to config/application.rb or conifg/environments/*
  #
  #     config.action_dispatch.trusted_proxies = RemoteIpProxyScrubber.rails_4_1([
  #       "216.73.93.70/31", # www.google.com
  #       "216.73.93.72/31", # www.google.com
  #       "17.0.0.0/8",      # Apple
  #     ])
  def self.rails_4_1(*given_ips)
    list = IPList.new(given_ips)
    regexps = list.each do |ip_addr|
      Regexp.new(Regexp.escape(ip_addr.to_range.first))
    end
    Regexp.union(*regexps)
  end
end