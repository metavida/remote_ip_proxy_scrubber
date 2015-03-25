require File.dirname(__FILE__) + '/../lib/remote_ip_proxy_scrubber'

# Define a few items that we'll stub out during out tests
class Rails
  def self.version
    raise 'this method must be stubbed in our tests'
  end
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
    rails_versions_to_test = {
      :rails_4_2  => %w{4.2.0 4.2.21 4.3.3 5.0.0},
      :rails_4_0  => %w{4.0.0 4.1.10 4.1.42},
      :rails_3    => %w{3.0.0 3.1.4 3.2.21 3.99.999},
    }

    rails_versions_to_test.each do |expected_method, current_rails_versions|
      current_rails_versions.each do |rails_version|
        it "should call RailsVersions.#{expected_method} for Rails #{rails_version}" do
          # Given
          expect(Rails).to receive(:version) { rails_version }
          ips = ['random values', 1.0]

          # Then
          expect(RemoteIpProxyScrubber::RailsVersions).to receive(expected_method) { ips }

          # When
          RemoteIpProxyScrubber.config(ips)
        end
      end
    end

    rails_versions_to_fail = %w{1.0.0 1.2.6 2.0.0 2.99.99 not.a.version}

    rails_versions_to_fail.each do |rails_version|
      it "should fail for Rails #{rails_version}" do
        # Given
        expect(Rails).to receive(:version) { rails_version }
        ips = ['random values', 1.0]

        # Then/When
        expect {
          RemoteIpProxyScrubber.config(ips)
        }.to raise_error
      end
    end

    it "should fail if there is no Rails version" do
      # Given
      expect(Rails).to receive(:version) { fail NoMethodError.new("No Rails") }
      ips = ['random values', 1.0]

      # Then/When
      expect {
        RemoteIpProxyScrubber.config(ips)
      }.to raise_error
    end

  end

  describe ".rails_version" do
    it "should prefer Rails.version if available" do
      # Given
      expected_version    = Gem::Version.new('0.0.1')
      unexpected_version  = Gem::Version.new('0.0.2')
      expect(Rails).to receive(:version) { expected_version.to_s }
      redefine_const(Object, :RAILS_GEM_VERSION, unexpected_version.to_s) do

        # Then
        expect(RemoteIpProxyScrubber.rails_version).to be == expected_version
      end
    end

    it "should use RAILS_VERSION if Rails.version isn't available" do
      # Given
      expected_version    = Gem::Version.new('0.0.1')
      expect(Rails).to receive(:version) { fail NoMethodError.new("No Rails") }
      redefine_const(Object, :RAILS_GEM_VERSION, expected_version.to_s) do

        # Then
        expect(RemoteIpProxyScrubber.rails_version).to be == expected_version
      end
    end

    it "should fail if it can't figure out the version" do
      # Given
      expect(Rails).to receive(:version) { nil }
      redefine_const(Object, :RAILS_GEM_VERSION, nil) do

        # Then
        expect {
          RemoteIpProxyScrubber.rails_version
        }.to raise_error
      end
    end
  end
end