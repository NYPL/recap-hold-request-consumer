# -*- encoding: utf-8 -*-
# stub: aws-kclrb 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-kclrb".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Amazon Web Services".freeze]
  s.date = "2017-01-19"
  s.description = "A ruby interface for the Amazon Kinesis Client Library MultiLangDaemon".freeze
  s.homepage = "http://github.com/aws/amazon-kinesis-client-ruby".freeze
  s.licenses = ["Amazon Software License".freeze]
  s.rubygems_version = "2.7.9".freeze
  s.summary = "Amazon Kinesis Client Library for Ruby".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<multi_json>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.0"])
  end
end
