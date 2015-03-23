require 'remote_ip_proxy_scrubber/ip_list'

module RemoteIpProxyScrubber
  class RailsVersions
    class << self
      # Supports Rails >= 4.2.0
      #
      # given_ips are one or more String, IPAddr, and/or Regex
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
        elsif given_ips.empty?
          no_proxies_warning
          nil
        else
          given_ips
        end
      end

      # Supports Rails 4.0.x -> 4.1.x
      #
      # given_ips are one or more String, IPAddr, and/or Regex
      #
      # Available options
      # * :include_trusted_proxies: A boolean. Default true
      #
      # In these versions of Rails
      # custom_procies can be a Regexp which will replace TRUSTED_PROXIES
      # or a String which will be used in addition to TRUSTED_PROXIES
      #
      # To keep things simple, this method will always return a Regexp
      # and if `:include_trusted_proxies == true` it will add in TRUSTED_PROXIES
      #
      # * https://github.com/rails/rails/blob/v4.0.0/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L50-L56
      # * https://github.com/rails/rails/blob/v4.1.10/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L50-L56
      def rails_4_0(*given_ips)
        options = given_ips.extract_options!
        options.reverse_merge!(:include_trusted_proxies=>true)

        given_regexps, given_ips = split_regexp_and_other(*given_ips)

        final_regexps = []
        final_regexps += given_regexps unless given_regexps.empty?
        final_regexps << IPList.new(*given_ips).to_regexp unless given_ips.empty?
        final_regexps << ::ActionDispatch::RemoteIp::TRUSTED_PROXIES if options[:include_trusted_proxies]

        if final_regexps.empty?
          no_proxies_warning
          nil
        else
          Regexp.union(*final_regexps)
        end
      end

      # Supports Rails 3.x
      #
      # Fixed options
      # * :include_trusted_proxies: Only supports true
      #
      # In these versions of Rails
      # custom_procies could be a Regexp or a String
      # this value will always be used in addition to TRUSTED_PROXIES
      #
      # To keep things simple, this method will always return a Regexp
      #
      # * https://github.com/rails/rails/blob/v3.0.0/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L42
      # * https://github.com/rails/rails/blob/v3.1.12/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L42
      # * https://github.com/rails/rails/blob/v3.2.0/actionpack/lib/action_dispatch/middleware/remote_ip.rb#L18-L27
      # * https://github.com/rails/rails/blob/v3.2.21/actionpack/lib/action_dispatch/middleware/remote_ip.rb
      def rails_3(*given_ips)
        options = given_ips.extract_options!
        options.reverse_merge!(:include_trusted_proxies=>true)
        warn_unless_include_trusted_proxies(options)

        given_regexps, given_ips = split_regexp_and_other(*given_ips)

        final_regexps = []
        final_regexps += given_regexps unless given_regexps.empty?
        final_regexps << IPList.new(*given_ips).to_regexp unless given_ips.empty?

        if final_regexps.empty?
          no_proxies_warning
          nil
        else
          Regexp.union(*final_regexps)
        end
      end

      private

      def split_regexp_and_other(*given_values)
        regexps = []
        ips = []
        given_values.each do |val|
          case val
          when Regexp
            regexps << val
          else
            ips << val
          end
        end
        [regexps, ips]
      end

      def no_proxies_warning
        warn "No proxies were specified. Using TRUSTED_PROXIES by default."
      end

      def warn_unless_include_trusted_proxies(options)
        return if options[:include_trusted_proxies]
        warn "Sorry, this version of Rails always includes TRUSTED_PROXIES"
      end

    end
  end
end