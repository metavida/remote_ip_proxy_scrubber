require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber'

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

describe RemoteIpProxyScrubber::RailsVersions do

  describe ".rails_4_2" do
    # Setup
    ::ActionDispatch::RemoteIp::TRUSTED_PROXIES = ['127.0.0.1']

    # Test every possible variation of arguments
    input_argmuent_variations.each do |args|
      it "should return an Array, given #{args.inspect}" do
        expect(RemoteIpProxyScrubber::RailsVersions.rails_4_2(*args)).to be_a(Array)
      end

    end
  end

end

