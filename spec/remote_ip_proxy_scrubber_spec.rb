require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber'

describe RemoteIpProxyScrubber do
  describe ".rails_4_1" do
    it "should return a Regexp" do
      expect(RemoteIpProxyScrubber.rails_4_1("8.8.8.8")).to be_a(Regexp)
    end

    it "should accept multiple IP addresses" do
      expect(RemoteIpProxyScrubber.rails_4_1("8.8.8.8", "8.8.9.0/32")).to be_a(Regexp)
    end
  end
end