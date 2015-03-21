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
  def rails_4_1(*given_ips)
    IPList.new(*given_ips).to_regexp
  end
  module_function :rails_4_1
end