# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jruby-elasticsearch/version"

Gem::Specification.new do |s|
  s.name        = "jruby-elasticsearch"
  s.version     = ElasticSearch::VERSION
  s.authors     = ["Jordan Sissel", "Mathias Biilmann"]
  s.email       = ["jls@semicomplete.com"]
  s.homepage    = "https://github.com/jordansissel/jruby-elasticsearch"
  s.summary     = "JRuby API for ElasticSearch using the native ES Java API"
  s.description = "..."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_development_dependency "jruby-elasticsearch_jars"
  s.add_development_dependency "json"
  
  s.platform = "java"
end