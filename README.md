Bash scanner for highlighting scripts with CodeRay
==================================================

### Instalation

    gem install coderay_bash

### Usage

    require 'rubygems'
    require 'coderay_bash'

    plain = File.read('some_script.sh')
    @body = CodeRay.scan(plain, :bash).div

### in your template then do something like

    <%= @body %>

### Types

* `:bash`
* `:erb_bash` -- erb code in bash strings

For more information see [CodeRay web pages](http://coderay.rubychan.de/)
