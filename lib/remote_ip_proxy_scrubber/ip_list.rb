require 'ipaddr'

module RemoteIpProxyScrubber
  class IPList
    def initalize(*given_ips)
      IPList(given_ips)
    end

    def add_ips(*given_ips)
      @proxy_ips ||= []
      given_ips.each do |ip|
        ip = IPAddr.new(ip) rescue nil
        @proxy_ips << ip if ip
      end
      proxy_ips
    end

    def proxy_ips
      @proxy_ips ||= []
    end
  end
end