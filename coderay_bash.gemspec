# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2
# 
# @author: Petr Kovar <pejuko@gmail.com>

require 'rubygems'
require 'find'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Simple bash scanner for highlighting with coderay."
  s.homepage = "http://github.com/pejuko/coderay_bash"
  s.email = "pejuko@gmail.com"
  s.authors = ["Petr Kovar"]
  s.name = 'coderay_bash'
  s.version = '0.1.3'
  s.date = Time.now.strftime("%Y-%m-%d")
  s.add_dependency('coderay', '< 1.0')
  s.require_path = 'lib'
  s.files = ["README.md", "coderay_bash.gemspec", "Rakefile"]
  s.files += Dir["lib/**/*.rb"]
  s.post_install_message = <<EOF
This gem was tested with coderay 0.9.3 and won't work with coderay from svn.
EOF
  s.description = <<EOF
This gem was tested with coderay 0.9.3 and won't work with coderay from svn.
EOF
end

