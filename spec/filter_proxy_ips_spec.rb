require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber/filter_proxy_ips'
include SpecHelper


# Returns an Array of input argument combinations that should always be tested
def input_argmuent_variations
  return @variations if @variations

  @variations = []

  single_args = [
    '8.8.8.8',                # single string
    '8.8.8.0/24',             # single string range
    IPAddr.new('8.8.8.8'),    # single IPAddr
    IPAddr.new('8.8.8.0/24'), # single IPAddr range
    /8.8.8.*/,                # single Regexp
  ]

  single_args.each do |first_arg|
    @variations << [first_arg]
    single_args.each do |second_arg|
      @variations << [first_arg, second_arg]
    end
  end

  # Add a "crazy Array" variation
  @variations << [[single_args[0], [single_args[1]]]]

  @variations
end

describe RemoteIpProxyScrubber::Rails4::FilterProxyIPs do

  describe ".initialize" do
    # Test every possible variation of arguments
    input_argmuent_variations.each do |args|
      it "should set @proxies to an Array of Regexp and IPAddr, given #{args.inspect}" do
        proxies = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(:app, *args).proxies
        expect(proxies).to be_a(Array)
        proxies.each do |proxy|
          expect(proxy).to be_a(Regexp).or be_a(IPAddr)
        end
      end
    end
  end

  describe ".call" do
    it "should remove a single IP with a simple String" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app, '17.0.0.1')

      # Then
      env = double("env")
      allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { '8.8.8.8, 17.0.0.1' }
      expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '8.8.8.8')

      # When
      proxy_filter.call(env)
    end

    it "should remove multiple IPs with a simple String" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app, '17.0.0.1')

      # Then
      env = double("env")
      allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { '8.8.8.8, 17.0.0.1, 17.0.0.2, 17.0.0.1' }
      expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '8.8.8.8, 17.0.0.2')

      # When
      proxy_filter.call(env)
    end

    it "should remove multiple IPs with a range String" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app, '17.0.0.0/4')

      # Then
      env = double("env")
      allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { '8.8.8.8, 17.0.0.1, 17.0.0.2, 127.0.0.1' }
      expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '8.8.8.8, 127.0.0.1')

      # When
      proxy_filter.call(env)
    end

    it "should remove multiple IPs with a simple IPAddr" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app, IPAddr.new('17.0.0.1'))

      # Then
      env = double("env")
      allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { '8.8.8.8, 17.0.0.1, 17.0.0.2, 17.0.0.1' }
      expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '8.8.8.8, 17.0.0.2')

      # When
      proxy_filter.call(env)
    end

    it "should remove multiple IPs with a range IPAddr" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app, IPAddr.new('17.0.0.0/4'))

      # Then
      env = double("env")
      allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { '8.8.8.8, 17.0.0.1, 17.0.0.2, 127.0.0.1' }
      expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '8.8.8.8, 127.0.0.1')

      # When
      proxy_filter.call(env)
    end

    it "should remove IPs with a Regexp" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app, /^17\./)

      # Then
      env = double("env")
      allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { '170.0.0.1, 17.0.0.1, 9.8.7.6, 17.254.0.1' }
      expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '170.0.0.1, 9.8.7.6')

      # When
      proxy_filter.call(env)
    end

    it "should NOT remove IPs with no proxy_matches" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app)

      # Then
      env = double("env")
      allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { '170.0.0.1, 17.0.0.1, 9.8.7.6, 17.254.0.1' }
      expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '170.0.0.1, 17.0.0.1, 9.8.7.6, 17.254.0.1')

      # When
      proxy_filter.call(env)
    end

    it "should silently remove invalid IPs in the header" do
      # Given
      app = double('app').as_null_object
      proxy_filter = RemoteIpProxyScrubber::Rails4::FilterProxyIPs.new(app)

      invalid_ips = [
        '127.0.0.500',
        '17.0.0.1/4',
        '17.0.0.1/500',
        'not an IP',
      ]

      # Then
      env = double("env")
      invalid_ips.each do |invalid|
        allow(env).to receive(:[]).with('HTTP_X_FORWARDED_FOR') { "#{invalid}, 127.0.0.1" }
        expect(env).to receive(:[]=).with('HTTP_X_FORWARDED_FOR', '127.0.0.1')

        # When
        proxy_filter.call(env)
      end
    end
  end

end

