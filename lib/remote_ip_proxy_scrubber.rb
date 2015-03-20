$:.unshift File.dirname(__FILE__)

require 'net/http'

require 'remote_ip_proxy_scrubber/version'
require 'remote_ip_proxy_scrubber/ip_list'

module RemoteIpProxyScrubber
  def self.rails_3(*given_ips)
    IPList.new(given_ips)
  end
end