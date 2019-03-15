# -*- encoding: utf-8 -*-
# stub: avro_schema_registry-client 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "avro_schema_registry-client".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Salsify, Inc".freeze]
  s.date = "2017-06-01"
  s.description = "Client for the avro-schema-registry app".freeze
  s.email = ["engineering@salsify.com".freeze]
  s.executables = ["console".freeze, "setup".freeze]
  s.files = ["bin/console".freeze, "bin/setup".freeze]
  s.homepage = "https://github.com/salsify/avro_schema_registry-client".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.9".freeze
  s.summary = "Client for the avro-schema-registry app".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.12"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4"])
      s.add_development_dependency(%q<salsify_rubocop>.freeze, ["~> 0.47.2"])
      s.add_development_dependency(%q<overcommit>.freeze, [">= 0"])
      s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<sinatra>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<avro_turf>.freeze, [">= 0.8.0"])
      s.add_runtime_dependency(%q<avro-resolution_canonical_form>.freeze, [">= 0.2.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
      s.add_dependency(%q<salsify_rubocop>.freeze, ["~> 0.47.2"])
      s.add_dependency(%q<overcommit>.freeze, [">= 0"])
      s.add_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<sinatra>.freeze, [">= 0"])
      s.add_dependency(%q<avro_turf>.freeze, [">= 0.8.0"])
      s.add_dependency(%q<avro-resolution_canonical_form>.freeze, [">= 0.2.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
    s.add_dependency(%q<salsify_rubocop>.freeze, ["~> 0.47.2"])
    s.add_dependency(%q<overcommit>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<sinatra>.freeze, [">= 0"])
    s.add_dependency(%q<avro_turf>.freeze, [">= 0.8.0"])
    s.add_dependency(%q<avro-resolution_canonical_form>.freeze, [">= 0.2.0"])
  end
end
