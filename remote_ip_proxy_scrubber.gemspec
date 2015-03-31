# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'remote_ip_proxy_scrubber/version'

Gem::Specification.new do |s|
  s.name = "remote_ip_proxy_scrubber"
  s.version = RemoteIpProxyScrubber::Version.to_s

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcos Wright-Kuhns"]
  s.date = "2015-03-20"
  s.description = "Make it as easy as possible to prevent Rails from logging IP addresses that belong to proxy devices in your HTTP request chain."
  s.email = "marcos@wrightkuhns.com"
  s.homepage = "http://github.com/metavida/remote_ip_proxy_scrubber"
  s.licenses = ["MIT"]

  s.files = `git ls-files`.split("\n")
  s.test_files = s.files.grep(%r{^(test|spec|features,integration_test)/})

  s.require_paths = ["lib"]
  s.rubygems_version = "2.4.6"
  s.summary = "Help Rails ignore IPs for proxy devices"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
  end
end

