require 'coderay'
path = File.join File.expand_path(File.dirname(__FILE__)), "coderay/scanners/bash.rb"
p path
require path
