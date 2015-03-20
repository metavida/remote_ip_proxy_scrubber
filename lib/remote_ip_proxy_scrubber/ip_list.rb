require 'ipaddr'

module RemoteIpProxyScrubber
  class IPList
    include Enumerable

    def initialize(*given_ips)
      add_ips(*given_ips)
    end

    def add_ips(*given_ips)
      @proxy_ips ||= []
      given_ips.each do |ip|
        @proxy_ips << case ip
        when IPAddr
          ip
        else
          IPAddr.new(ip)
        end
      end
      proxy_ips
    end

    def proxy_ips
      @proxy_ips ||= []
    end

    def each
      proxy_ips.each { |ip| yield(ip) }
    end
  end
end