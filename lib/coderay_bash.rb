require 'coderay'

path = File.join File.expand_path(File.dirname(__FILE__))

require File.join(path, "coderay/scanners/bash.rb")
require File.join(path, "coderay/scanners/erb_bash.rb")
