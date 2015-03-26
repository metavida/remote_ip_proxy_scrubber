$:.unshift File.dirname(__FILE__)

require 'remote_ip_proxy_scrubber/version'

module RemoteIpProxyScrubber
  # Add the following to config/application.rb or conifg/environments/*
  #
  #     config.action_dispatch.trusted_proxies = RemoteIpProxyScrubber.config([
  #       "216.73.93.70/31", # www.google.com
  #       "216.73.93.72/31", # www.google.com
  #       "17.0.0.0/8",      # Apple
  #     ])
  def config(*given_ips)
    require 'remote_ip_proxy_scrubber/trusted_proxy_values'

    given_ips = given_ips.flatten

    rails_version = self.rails_version
    if    rails_version >= Gem::Version.new('4.2.0')
      RemoteIpProxyScrubber::TrustedProxyValues.rails_4_2(*given_ips)
    elsif rails_version >= Gem::Version.new('4.0.0')
      RemoteIpProxyScrubber::TrustedProxyValues.rails_4_0(*given_ips)
    elsif rails_version >= Gem::Version.new('3.0.0')
      RemoteIpProxyScrubber::TrustedProxyValues.rails_3(*given_ips)
    else
      fail "Sorry, this gem doesn't know how to generate a trusted_proxies config value for Rails #{rails_version} yet."
    end
  end
  module_function :config

  def filter_middleware
    require 'remote_ip_proxy_scrubber/filter_proxy_ips'

    RemoteIpProxyScrubber::Rails4::FilterProxyIPs
  end
  module_function :filter_middleware

  # Returns a Class to be used a rack middleware,
  # replacing the existing `Rails::Rack::Logger`.
  #
  #     config.middleware.insert_before(Rails::Rack::Logger, RemoteIpProxyScrubber.patched_logger)
  #     config.middleware.delete(Rails::Rack::Logger)
  def patched_logger
    require 'remote_ip_proxy_scrubber/remote_ip_logger'

    rails_version = self.rails_version
    if    rails_version >= Gem::Version.new('4.0.0')
      RemoteIpProxyScrubber::Rails4::RemoteIPLogger
    elsif rails_version >= Gem::Version.new('3.2.9')
      RemoteIpProxyScrubber::Rails3_2_9::RemoteIPLogger
    elsif rails_version >= Gem::Version.new('3.2.0')
      RemoteIpProxyScrubber::Rails3_2_0::RemoteIPLogger
    elsif rails_version >= Gem::Version.new('3.0.6')
      RemoteIpProxyScrubber::Rails3_1::RemoteIPLogger
    elsif rails_version >= Gem::Version.new('3.0.0')
      RemoteIpProxyScrubber::Rails3_0::RemoteIPLogger
    else
      fail "Sorry, this gem doesn't know how to monkey-patch the Rails logger for Rails #{rails_version} yet."
    end
  end
  module_function :patched_logger

  def rails_version
    rails_version = Rails.version rescue nil
    rails_version ||= RAILS_GEM_VERSION rescue nil
    if rails_version.nil?
      fail "Unable to determine the current version of Rails"
    end
    Gem::Version.new(rails_version)
  end
  module_function :rails_version

end