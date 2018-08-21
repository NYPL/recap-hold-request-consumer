# -*- encoding: utf-8 -*-
# stub: avro_turf 0.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "avro_turf"
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Daniel Schierbeck"]
  s.date = "2017-03-06"
  s.email = ["dasch@zendesk.com"]
  s.homepage = "https://github.com/dasch/avro_turf"
  s.licenses = ["MIT"]
  s.post_install_message = "\navro_turf v0.8.0 deprecates the names AvroTurf::SchemaRegistry,\nAvroTurf::CachedSchemaRegistry, and FakeSchemaRegistryServer.\n\nUse AvroTurf::ConfluentSchemaRegistry, AvroTurf::CachedConfluentSchemaRegistry,\nand FakeConfluentSchemaRegistryServer instead.\n\nSee https://github.com/dasch/avro_turf#deprecation-notice\n"
  s.rubygems_version = "2.5.1"
  s.summary = "A library that makes it easier to use the Avro serialization format from Ruby"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<avro>, ["< 1.9", ">= 1.7.7"])
      s.add_runtime_dependency(%q<excon>, ["~> 0.45"])
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_development_dependency(%q<fakefs>, ["~> 0.6.7"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<json_spec>, [">= 0"])
    else
      s.add_dependency(%q<avro>, ["< 1.9", ">= 1.7.7"])
      s.add_dependency(%q<excon>, ["~> 0.45"])
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_dependency(%q<fakefs>, ["~> 0.6.7"])
      s.add_dependency(%q<webmock>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<json_spec>, [">= 0"])
    end
  else
    s.add_dependency(%q<avro>, ["< 1.9", ">= 1.7.7"])
    s.add_dependency(%q<excon>, ["~> 0.45"])
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, ["~> 3.2.0"])
    s.add_dependency(%q<fakefs>, ["~> 0.6.7"])
    s.add_dependency(%q<webmock>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<json_spec>, [">= 0"])
  end
end
