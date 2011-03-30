# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2
# 
# @author: Petr Kovar <pejuko@gmail.com>
$KCODE='UTF8' if RUBY_VERSION < "1.9"

require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/clean'

CLEAN << "coverage" << "pkg" << "README.html" << "CHANGELOG.html"

task :default => [:test, :gem]
Rake::GemPackageTask.new(eval(File.read("coderay_bash.gemspec"))) {|pkg|}

Rake::TestTask.new(:test) do |t|
  t.pattern = File.join(File.dirname(__FILE__), 'test/test.rb')
  t.verbose = true
end

