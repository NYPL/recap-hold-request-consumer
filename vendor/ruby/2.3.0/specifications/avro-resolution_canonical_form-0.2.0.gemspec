# -*- encoding: utf-8 -*-
# stub: avro-resolution_canonical_form 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "avro-resolution_canonical_form"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Salsify, Inc"]
  s.date = "2017-05-31"
  s.description = "Unique identification of Avro schemas for schema resolution"
  s.email = ["engineering@salsify.com"]
  s.executables = ["console", "setup"]
  s.files = ["bin/console", "bin/setup"]
  s.homepage = "https://github.com/salsify/avro-resolution_canonical_form"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Unique identification of Avro schemas for schema resolution"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.12"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.4"])
      s.add_development_dependency(%q<salsify_rubocop>, ["~> 0.46.0"])
      s.add_development_dependency(%q<overcommit>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_runtime_dependency(%q<avro-patches>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.12"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, ["~> 3.4"])
      s.add_dependency(%q<salsify_rubocop>, ["~> 0.46.0"])
      s.add_dependency(%q<overcommit>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<avro-patches>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.12"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, ["~> 3.4"])
    s.add_dependency(%q<salsify_rubocop>, ["~> 0.46.0"])
    s.add_dependency(%q<overcommit>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<avro-patches>, [">= 0"])
  end
end
