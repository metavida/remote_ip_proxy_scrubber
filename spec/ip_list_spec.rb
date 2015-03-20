require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber'

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
end