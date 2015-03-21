require 'ipaddr'
require 'range_regexp'

module RemoteIpProxyScrubber
  class IPList
    include Enumerable

    def initialize(*given_ips)
      add_ips(*given_ips)
    end

    # Add one ore more IP addresses to the proxy_ips array
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

    # Returns an Array of IPAddr values
    def proxy_ips
      @proxy_ips ||= []
    end

    # Returns a Regexp that matches any IP address in proxy_ips
    def to_regexp
      Regexp.union(*proxy_ips.map { |ip| ip_addr_to_regexp(ip) })
    end

    # Iterate over the proxy_ips
    def each
      proxy_ips.each { |ip| yield(ip) }
    end

    private

    def ip_addr_to_regexp(ip)
      range = ip.to_range
      regexp_sources_for_range = (
        if range.first == range.last
          [ip]
        else
          low_octets  = split_octets(range.first)
          high_octets = split_octets(range.last)

          regexp_array = []
          4.times do |octet_index|
            regexp_array << octet_pair_to_regexp_source(low_octets[octet_index], high_octets[octet_index])
          end
          regexp_array
        end
      )

      Regexp.new('\A' + regexp_sources_for_range.join('\.') + '\z')
    end

    def split_octets(ip)
      ip.to_s.split('.')
    end

    def octet_pair_to_regexp_source(low_octet, high_octet)
      if low_octet == high_octet
        low_octet
      else
        RangeRegexp.new(low_octet..high_octet).regexp.source
      end
    end
  end
end