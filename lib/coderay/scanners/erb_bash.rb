# Scanner for Bash
# Author: spam+github@codez.ch
require 'coderay/scanners/rhtml'

module CodeRay
  module Scanners
    class ErbBash < RHTML
      register_for :erb_bash

      protected
      def setup
        super
        # Scan Bash instead of HTML template
        @html_scanner = CodeRay.scanner :bash, @options.merge(:tokens => @tokens, :keep_tokens => true)
      end
    end
  end
end
