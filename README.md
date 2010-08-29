Bash scanner for highlighting scripts with CodeRay
==================================================

### Instalation

    gem install coderay_bash

### Usage

    require 'rubygems'
    require 'coderay_bash'

    plain = File.read('some_script.sh')
    @body = CodeRay.scan(plain, :bash).div

### in your template then do some thing like

    <%= @body %>

For more information see [CodeRay we pages](http://coderay.rubychan.de/)
