require 'ipaddr'
require 'range_regexp'

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

    def to_regexp
      Regexp.union(*proxy_ips.map do |ip|
        range = ip.to_range
        if range.first == range.last
          Regexp.new("\\A#{ip}\\z")
        else
          low_ip_array  = range.first.to_s.split('.')
          high_ip_array = range.last.to_s.split('.')

          regexp_array = []
          low_ip_array.each_with_index do |low_octet, octet_index|
            high_octet = high_ip_array[octet_index]
            if low_octet == high_octet
              regexp_array << low_octet
            else
              regexp_array << RangeRegexp.new(low_octet..high_octet).regexp.source
            end
          end
          Regexp.new('\A' + regexp_array.join('\.') + '\z')
        end
      end)
    end
  end
end