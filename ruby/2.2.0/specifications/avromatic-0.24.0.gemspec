# -*- encoding: utf-8 -*-
# stub: avromatic 0.24.0 ruby lib

Gem::Specification.new do |s|
  s.name = "avromatic".freeze
  s.version = "0.24.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Salsify Engineering".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-06-08"
  s.description = "Generate Ruby models from Avro schemas".freeze
  s.email = ["engineering@salsify.com".freeze]
  s.homepage = "https://github.com/salsify/avromatic.git".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.9".freeze
  s.summary = "Generate Ruby models from Avro schemas".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<avro>.freeze, [">= 1.7.7"])
      s.add_runtime_dependency(%q<virtus>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.1", "< 5.1"])
      s.add_runtime_dependency(%q<activemodel>.freeze, [">= 4.1", "< 5.1"])
      s.add_runtime_dependency(%q<avro_turf>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<avro_schema_registry-client>.freeze, [">= 0.3.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.11"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_development_dependency(%q<avro-builder>.freeze, [">= 0.12.0"])
      s.add_development_dependency(%q<sinatra>.freeze, [">= 0"])
      s.add_development_dependency(%q<salsify_rubocop>.freeze, ["~> 0.48.0"])
      s.add_development_dependency(%q<overcommit>.freeze, ["= 0.35.0"])
      s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
    else
      s.add_dependency(%q<avro>.freeze, [">= 1.7.7"])
      s.add_dependency(%q<virtus>.freeze, [">= 0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 4.1", "< 5.1"])
      s.add_dependency(%q<activemodel>.freeze, [">= 4.1", "< 5.1"])
      s.add_dependency(%q<avro_turf>.freeze, [">= 0"])
      s.add_dependency(%q<avro_schema_registry-client>.freeze, [">= 0.3.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.11"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_dependency(%q<avro-builder>.freeze, [">= 0.12.0"])
      s.add_dependency(%q<sinatra>.freeze, [">= 0"])
      s.add_dependency(%q<salsify_rubocop>.freeze, ["~> 0.48.0"])
      s.add_dependency(%q<overcommit>.freeze, ["= 0.35.0"])
      s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<avro>.freeze, [">= 1.7.7"])
    s.add_dependency(%q<virtus>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 4.1", "< 5.1"])
    s.add_dependency(%q<activemodel>.freeze, [">= 4.1", "< 5.1"])
    s.add_dependency(%q<avro_turf>.freeze, [">= 0"])
    s.add_dependency(%q<avro_schema_registry-client>.freeze, [">= 0.3.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.11"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_dependency(%q<avro-builder>.freeze, [">= 0.12.0"])
    s.add_dependency(%q<sinatra>.freeze, [">= 0"])
    s.add_dependency(%q<salsify_rubocop>.freeze, ["~> 0.48.0"])
    s.add_dependency(%q<overcommit>.freeze, ["= 0.35.0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
  end
end
