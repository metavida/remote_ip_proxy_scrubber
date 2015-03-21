require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber'

# Define a few items that we'll stub out during out tests
class Rails
  def self.version
    raise 'this method must be stubbed in our tests'
  end
end
module ActionDispatch
  class RemoteIp; end
end

# Backport the Rails methods we need for testing
class Hash
  def reverse_merge!(other_hash)
    replace(other_hash.merge(self))
  end
end
class Array
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

describe RemoteIpProxyScrubber do
  describe ".config" do
    it "should return a Regexp for Rails 4.0.0" do
      expect(Rails).to receive(:version) { '4.0.0' }
      ActionDispatch::RemoteIp::TRUSTED_PROXIES = /trusted/

      expect(RemoteIpProxyScrubber.config("8.8.8.8")).to be_a(Regexp)
    end

    it "should return an Array for Rails 4.2.0" do
      expect(Rails).to receive(:version) { '4.2.0' }
      ActionDispatch::RemoteIp::TRUSTED_PROXIES = ['trusted']

      expect(RemoteIpProxyScrubber.config("8.8.8.8")).to be_a(Array)
    end
  end
end