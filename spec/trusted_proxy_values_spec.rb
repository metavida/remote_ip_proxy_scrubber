require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber'
include SpecHelper

# Define a few items that we'll stub out during out tests
module ActionDispatch
  class RemoteIp; end
end

# Returns an Array of input argument combinations that should always be tested
def input_argmuent_variations
  return @variations if @variations

  @variations = []

  # include_trusted_proxies
  [true, false, nil].each do |include_trusted_proxies_val|

    single_args = [
      '8.8.8.8',                # single string
      '8.8.8.0/24',             # single string range
      IPAddr.new('8.8.8.8'),    # single IPAddr
      IPAddr.new('8.8.8.0/24'), # single IPAddr range
      /8.8.8.*/,                # single Regexp
    ]

    single_args.each do |first_arg|

      case include_trusted_proxies_val
      when nil
        @variations << [first_arg]
        single_args.each do |second_arg|
          @variations << [first_arg, second_arg]
        end
      else
        @variations << [first_arg, {:include_trusted_proxies=>include_trusted_proxies_val}]
        single_args.each do |second_arg|
          @variations << [first_arg, second_arg, {:include_trusted_proxies=>include_trusted_proxies_val}]
        end
      end

    end
  end

  @variations
end

describe RemoteIpProxyScrubber::TrustedProxyValues do

  describe ".rails_4_2" do
    # Test every possible variation of arguments
    input_argmuent_variations.each do |args|
      it "should return an Array, given #{args.inspect}" do
        redefine_const(::ActionDispatch::RemoteIp, :TRUSTED_PROXIES, ['127.0.0.1']) do
          expect(RemoteIpProxyScrubber::TrustedProxyValues).to_not receive(:warn)
          expect(RemoteIpProxyScrubber::TrustedProxyValues.rails_4_2(*args)).to be_a(Array)
        end
      end
    end

    it "should warn of fallback behavior if no IPs are given" do
      redefine_const(::ActionDispatch::RemoteIp, :TRUSTED_PROXIES, ['127.0.0.1']) do
        expect(RemoteIpProxyScrubber::TrustedProxyValues).to receive(:warn).with(/No proxies were specified/)
        expect(
          RemoteIpProxyScrubber::TrustedProxyValues.rails_4_2(:include_trusted_proxies=>false)
        ).to be_nil
      end
    end
  end

  describe ".rails_4_0" do
    # Test every other possible variation of arguments
    input_argmuent_variations.each do |args|
      it "should return an Array, given #{args.inspect}" do
        redefine_const(::ActionDispatch::RemoteIp, :TRUSTED_PROXIES, /127.0.0.1/) do
          expect(RemoteIpProxyScrubber::TrustedProxyValues).to_not receive(:warn)
          expect(RemoteIpProxyScrubber::TrustedProxyValues.rails_4_0(*args)).to be_a(Regexp)
        end
      end
    end

    it "should warn of fallback behavior if no IPs are given" do
      redefine_const(::ActionDispatch::RemoteIp, :TRUSTED_PROXIES, ['127.0.0.1']) do
        expect(RemoteIpProxyScrubber::TrustedProxyValues).to receive(:warn).with(/No proxies were specified/)
        expect(
          RemoteIpProxyScrubber::TrustedProxyValues.rails_4_0(:include_trusted_proxies=>false)
        ).to be_nil
      end
    end
  end


  describe ".rails_3" do
    # Test every possible variation of arguments
    input_argmuent_variations.each do |args|
      it "should return an Array, given #{args.inspect}" do
        if args.last.is_a?(Hash) && args.last[:include_trusted_proxies] == false
          expect(RemoteIpProxyScrubber::TrustedProxyValues).to receive(:warn).with(/always includes TRUSTED_PROXIES/)
        else
          expect(RemoteIpProxyScrubber::TrustedProxyValues).to_not receive(:warn)
        end

        expect(RemoteIpProxyScrubber::TrustedProxyValues.rails_3(*args)).to be_a(Regexp)
      end
    end

    it "should NOT warn of fallback behavior if no IPs are given" do
      # ...because there's no point in warning that TRUSTED_PROXIES will be used
      #    because TRUSTED_PROXIES is *always* used in rails_3
      redefine_const(::ActionDispatch::RemoteIp, :TRUSTED_PROXIES, ['127.0.0.1']) do
        expect(RemoteIpProxyScrubber::TrustedProxyValues).to receive(:warn).with(/always includes TRUSTED_PROXIES/)
        expect(RemoteIpProxyScrubber::TrustedProxyValues).to_not receive(:warn).with(/No proxies were specified/)
        expect(
          RemoteIpProxyScrubber::TrustedProxyValues.rails_3(:include_trusted_proxies=>false)
        ).to be_nil
      end
    end
  end

end

