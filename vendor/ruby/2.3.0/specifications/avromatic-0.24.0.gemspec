# -*- encoding: utf-8 -*-
# stub: avromatic 0.24.0 ruby lib

Gem::Specification.new do |s|
  s.name = "avromatic"
  s.version = "0.24.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Salsify Engineering"]
  s.bindir = "exe"
  s.date = "2017-06-08"
  s.description = "Generate Ruby models from Avro schemas"
  s.email = ["engineering@salsify.com"]
  s.homepage = "https://github.com/salsify/avromatic.git"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Generate Ruby models from Avro schemas"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<avro>, [">= 1.7.7"])
      s.add_runtime_dependency(%q<virtus>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, ["< 5.1", ">= 4.1"])
      s.add_runtime_dependency(%q<activemodel>, ["< 5.1", ">= 4.1"])
      s.add_runtime_dependency(%q<avro_turf>, [">= 0"])
      s.add_runtime_dependency(%q<avro_schema_registry-client>, [">= 0.3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.11"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<avro-builder>, [">= 0.12.0"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<salsify_rubocop>, ["~> 0.48.0"])
      s.add_development_dependency(%q<overcommit>, ["= 0.35.0"])
      s.add_development_dependency(%q<appraisal>, [">= 0"])
    else
      s.add_dependency(%q<avro>, [">= 1.7.7"])
      s.add_dependency(%q<virtus>, [">= 0"])
      s.add_dependency(%q<activesupport>, ["< 5.1", ">= 4.1"])
      s.add_dependency(%q<activemodel>, ["< 5.1", ">= 4.1"])
      s.add_dependency(%q<avro_turf>, [">= 0"])
      s.add_dependency(%q<avro_schema_registry-client>, [">= 0.3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.11"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
      s.add_dependency(%q<avro-builder>, [">= 0.12.0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<salsify_rubocop>, ["~> 0.48.0"])
      s.add_dependency(%q<overcommit>, ["= 0.35.0"])
      s.add_dependency(%q<appraisal>, [">= 0"])
    end
  else
    s.add_dependency(%q<avro>, [">= 1.7.7"])
    s.add_dependency(%q<virtus>, [">= 0"])
    s.add_dependency(%q<activesupport>, ["< 5.1", ">= 4.1"])
    s.add_dependency(%q<activemodel>, ["< 5.1", ">= 4.1"])
    s.add_dependency(%q<avro_turf>, [">= 0"])
    s.add_dependency(%q<avro_schema_registry-client>, [">= 0.3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.11"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
    s.add_dependency(%q<avro-builder>, [">= 0.12.0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<salsify_rubocop>, ["~> 0.48.0"])
    s.add_dependency(%q<overcommit>, ["= 0.35.0"])
    s.add_dependency(%q<appraisal>, [">= 0"])
  end
end
