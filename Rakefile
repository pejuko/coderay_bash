# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2
# 
# @author: Petr Kovar <pejuko@gmail.com>
$KCODE='UTF8'

require 'rake/gempackagetask'
require 'rake/clean'

CLEAN << "coverage" << "pkg" << "README.html" << "CHANGELOG.html"

task :default => [:gem]
Rake::GemPackageTask.new(eval(File.read("coderay_bash.gemspec"))) {|pkg|}

