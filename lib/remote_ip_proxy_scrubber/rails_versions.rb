require 'remote_ip_proxy_scrubber/ip_list'

module RemoteIpProxyScrubber
  class RailsVersions
    class << self
      # Supports Rails >= 4.2.0
      #
      # Available options
      # * :include_trusted_proxies: A boolean. Default true
      #
      # In these versions of Rails
      # custom_proxies can be an Array of String, IPAddr, or Regexp
      # which will replace TRUSTED_PROXIES
      # or a single String, IPAddr, or Regexp
      # which will be used in addition to TRUSTED_PROXIES
      #
      # To keep things simple, this method will always return an Array of items
      # and if `:include_trusted_proxies == true` it will add in TRUSTED_PROXIES
      #
      # * https://github.com/rails/rails/blob/v4.2.0/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L52-L59
      def rails_4_2(*given_ips)
        options = given_ips.extract_options!
        options.reverse_merge!(:include_trusted_proxies=>true)

        if options[:include_trusted_proxies]
          given_ips + ::ActionDispatch::RemoteIp::TRUSTED_PROXIES
        else
          given_ips
        end
      end

      # Supports Rails 4.0.x -> 4.1.x
      #
      # Available options
      # * :include_trusted_proxies: A boolean. Default true
      #
      # In these versions of Rails
      # custom_procies can only be a Regexp
      # and the Regexp value replaces the TRUSTED_PROXIES values
      # so we have to generate a new regexp, if we're given one or more String or IPAddr values
      # and we make it optional to override the TRUSTED_PROXIES
      #
      # * https://github.com/rails/rails/blob/v4.0.0/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L50-L56
      # * https://github.com/rails/rails/blob/v4.1.10/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L50-L56
      def rails_4_0(*given_ips)
        options = given_ips.extract_options!
        options.reverse_merge!(:include_trusted_proxies=>true)

        regexp = if given_ips.size == 1 && given_ips.is_a?(Regexp)
          given_ips
        else
          IPList.new(*given_ips).to_regexp
        end

        if options[:include_trusted_proxies]
          Regexp.union(regexp, ::ActionDispatch::RemoteIp::TRUSTED_PROXIES)
        else
          regexp
        end
      end

    end
  end
end