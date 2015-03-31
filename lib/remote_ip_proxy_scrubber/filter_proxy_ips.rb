require 'ipaddr'

module RemoteIpProxyScrubber
  module Rails4
    class FilterProxyIPs
      X_FORWARDED_FOR = 'HTTP_X_FORWARDED_FOR'

      attr_reader :proxies

      def initialize(app, *proxy_matchers)
        @app = app

        @proxies = []

        proxy_matchers.flatten.each do |matcher|
          @proxies << case matcher
          when Regexp, IPAddr
            matcher
          when String
            IPAddr.new(matcher)
          else
            raise ArgumentError.new("Expected String, IPAddr or Regexp but found #{matcher.class} #{matcher.inspect}")
          end
        end

      end

      def call(env)
        @env = env

        ips = ips_from(X_FORWARDED_FOR)
        @env[X_FORWARDED_FOR] = filter_proxies(ips).join(', ')

        @app.call(@env)
      end

      protected

      # Shamelssly copied from Rails 4.2
      # https://github.com/rails/rails/blob/v4.2.0/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L149-L168
      def ips_from(header)
        # Split the comma-separated list into an array of strings
        ips = @env[header] ? @env[header].strip.split(/[,\s]+/) : []
        ips.select do |ip|
          begin
            # Only return IPs that are valid according to the IPAddr#new method
            range = IPAddr.new(ip).to_range
            # we want to make sure nobody is sneaking a netmask in
            range.begin == range.end
          rescue ArgumentError
            nil
          end
        end
      end

      def filter_proxies(ips)
        ips.reject do |ip|
          @proxies.any? { |proxy| proxy === ip }
        end
      end
    end
  end
end