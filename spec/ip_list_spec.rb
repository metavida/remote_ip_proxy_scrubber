require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber/ip_list'

describe RemoteIpProxyScrubber::IPList do

  describe ".initialize" do
    it "should accept a single IP address" do
      expect {
        list = RemoteIpProxyScrubber::IPList.new("8.8.8.8")

        expect(list.proxy_ips.size).to eq(1)
      }.to_not raise_error
    end

    it "should accept a single IPAddr" do
      expect {
        list = RemoteIpProxyScrubber::IPList.new(IPAddr.new("8.8.8.8"))

        expect(list.proxy_ips.size).to eq(1)
      }.to_not raise_error
    end

    it "should accept a multiple IP address" do
      expect {
        list = RemoteIpProxyScrubber::IPList.new(
          "8.8.8.8",
          "9.9.9.9"
        )

        expect(list.proxy_ips.size).to eq(2)
      }.to_not raise_error
    end

    it "should throw an error given an invalid IP" do
      expect {
        RemoteIpProxyScrubber::IPList.new("500.0.0.1")
      }.to raise_error
    end
  end

  describe "#to_regexp" do
    it "should produce an exact regexp for a single IP address" do
      before  = "8.8.8.7"
      ip      = before.succ
      after   = ip.succ
      regexp  = RemoteIpProxyScrubber::IPList.new(ip).to_regexp

      expect(ip).to match(regexp)
      expect(before ).not_to match(regexp)
      expect(after  ).not_to match(regexp)
    end

    it "should produce an exact regexp for a multiple IP addresses" do
      before  = "8.8.8.7"
      first   = before.succ
      second  = first.succ
      after   = second.succ
      regexp  = RemoteIpProxyScrubber::IPList.new(first, second).to_regexp

      expect(first  ).to match(regexp)
      expect(second ).to match(regexp)
      expect(before ).not_to match(regexp)
      expect(after  ).not_to match(regexp)
    end

    it "should produce a regexp matching a range for an IP range" do
      ip_range  = IPAddr.new("8.8.8.124/30")
      before    = "8.8.8.123"
      after     = ip_range.to_range.last.to_s.succ
      regexp    = RemoteIpProxyScrubber::IPList.new(ip_range).to_regexp

      expect(ip_range.to_range.to_a.size).to be > 0

      ip_range.to_range.each do |ip|
        expect(ip.to_s).to match(regexp)
      end
      expect(before ).not_to match(regexp)
      expect(after  ).not_to match(regexp)
    end
  end
end