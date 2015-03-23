$:.unshift File.dirname(__FILE__)

require 'remote_ip_proxy_scrubber/version'
require 'remote_ip_proxy_scrubber/rails_versions'

module RemoteIpProxyScrubber
  # Add the following to config/application.rb or conifg/environments/*
  #
  #     config.action_dispatch.trusted_proxies = RemoteIpProxyScrubber.config([
  #       "216.73.93.70/31", # www.google.com
  #       "216.73.93.72/31", # www.google.com
  #       "17.0.0.0/8",      # Apple
  #     ])
  def config(*given_ips)
    rails_version = Rails.version rescue nil
    rails_version ||= RAILS_GEM_VERSION rescue nil
    if rails_version.nil?
      fail "Unable to determine the current version of Rails"
    end
    rails_version = Gem::Version.new(rails_version)

    if    rails_version >= Gem::Version.new('4.2.0')
      RemoteIpProxyScrubber::RailsVersions.rails_4_2(*given_ips)
    elsif rails_version >= Gem::Version.new('4.0.0')
      RemoteIpProxyScrubber::RailsVersions.rails_4_0(*given_ips)
    elsif rails_version >= Gem::Version.new('3.0.0')
      RemoteIpProxyScrubber::RailsVersions.rails_3(*given_ips)
    else
      fail "Sorry, this gem doesn't know how to handle Rails #{rails_version} yet"
    end
  end
  module_function :config
end