Bash scanner for highlighting scripts with CodeRay
==================================================

### Installation

```bash
gem install coderay_bash
```

### Usage

```ruby
require 'rubygems'
require 'coderay_bash'

plain = File.read('some_script.sh')
@body = CodeRay.scan(plain, :bash).div
```

### in your template then do something like

```html
<%= @body %>
```

### Types

* `:bash`
* `:erb_bash` -- erb code in bash strings

For more information see [CodeRay web pages](http://coderay.rubychan.de/)

### Licence

MIT
