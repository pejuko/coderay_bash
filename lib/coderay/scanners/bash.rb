# Scanner for Bash
# Author: Petr Kovar <pejuko@gmail.com>
module CodeRay
module Scanners
  class Bash < Scanner

    register_for :bash
    file_extension 'sh'
    title 'bash script'

    RESERVED_WORDS = %w(
      ! [[ ]] case do done elif else esac fi for function if in select then time until while { }
    )

    COMMANDS = %w(
      : . break cd continue eval exec exit export getopts hash pwd
      readonly return shift test [ ] times trap umask unset
    )

    BASH_COMMANDS = %w(
      alias bind builtin caller command declare echo enable help let
      local logout printf read set shopt source type typeset ulimit unalias
    )

    VARIABLES = %w(
      CDPATH HOME IFS MAIL MAILPATH OPTARG OPTIND PATH PS1 PS2
    )

    BASH_VARIABLES = %w(
      BASH BASH_ARGC BASH_ARGV BASH_COMMAND BASH_ENV BASH_EXECUTION_STRING
      BASH_LINENO BASH_REMATCH BASH_SOURCE BASH_SUBSHELL BASH_VERSINFO
      BASH_VERSINFO[0] BASH_VERSINFO[1] BASH_VERSINFO[2] BASH_VERSINFO[3] 
      BASH_VERSINFO[4] BASH_VERSINFO[5] BASH_VERSION COLUMNS COMP_CWORD
      COMP_LINE COMP_POINT COMP_WORDBREAKS COMP_WORDS COMPREPLAY DIRSTACK
      EMACS EUID FCEDIT FIGNORE FUNCNAME GLOBIGNORE GROUPS histchars HISTCMD
      HISTCONTROL HISTFILE HISTFILESIZE HISTIGNORE HISTSIZE HISTTIMEFORMAT
      HOSTFILE HOSTNAME HOSTTYPE IGNOREEOF INPUTRC LANG LC_ALL LC_COLLATE
      LC_CTYPE LC_MESSAGE LC_NUMERIC LINENNO LINES MACHTYPE MAILCHECK OLDPWD
      OPTERR OSTYPE PIPESTATUS POSIXLY_CORRECT PPID PROMPT_COMMAND PS3 PS4 PWD
      RANDOM REPLAY SECONDS SHELL SHELLOPTS SHLVL TIMEFORMAT TMOUT TMPDIR UID
    )

    PRE_CONSTANTS = / \$\{? (?: \# | \? | \d | \* | @ | - | \$ | \! | _ ) \}? /ox

    IDENT_KIND = WordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(COMMANDS, :method).
      add(BASH_COMMANDS, :method).
      add(VARIABLES, :pre_type).
      add(BASH_VARIABLES, :pre_type)

    attr_reader :state, :quote

    def initialize(*args)
      super(*args)
      @state = :initial
      @quote = nil
    end

    def scan_tokens tokens, options

      until eos?
        kind = match = nil

        if match = scan(/\n/)
          tokens << [match, :end_line]
          next
        end

        if @state == :initial
          if  match = scan(/\A#!.*/)
            kind = :directive
          elsif match = scan(/#.*/)
            kind = :comment
          elsif match = scan(/(?:\. |source ).*/)
            kind = :reserved
          elsif match = scan(/(?:\\.|,)/)
            kind = :plain
          elsif match = scan(/;/)
            kind = :delimiter
          elsif match = scan(/(?:"|`)/)
            @state = :quote
            @quote = match
            tokens << [:open, :string] if @quote == '"'
            tokens << [:open, :shell] if @quote == '`'
            tokens << [match, :delimiter]
            next
          elsif match = scan(/'[^']*'/)
            kind = :string
          elsif match = scan(/(?: \& | > | < | \| >> | << | >\& )/ox)
            kind = :bin
          elsif match = scan(/\d+[\.-](?:\d+[\.-]?)+/)
            #versions, dates, and hyphen delimited numbers
            kind = :float
          elsif match = scan(/\d+\.\d+\s+/)
            kind = :float
          elsif match = scan(/\d+/)
            kind = :integer
          elsif match = scan(/ (?: \$\(\( | \)\) ) /x)
            kind = :global_variable
          elsif match = scan(/ \$\{ [^\}]+ \} /ox)
            match =~ /\$\{(.*)\}/
            kind = IDENT_KIND[$1]
            kind = :instance_variable if kind == :ident
          elsif match = scan(/ \$\( [^\)]+ \) /ox)
            kind = :shell
          elsif match = scan(PRE_CONSTANTS)
            kind = :pre_constant
          elsif match = scan(/[^\s'"]*[A-Za-z_][A-Za-z_0-9]*\+?=/)
            match =~ /(.*?)([A-Za-z_][A-Za-z_0-9]*)(\+?=)/
            str = $1
            pre = $2
            op = $3
            kind = :plain
            if str.to_s.strip.empty?
              kind = IDENT_KIND[pre]
              kind = :instance_variable if kind == :ident
              tokens << [pre, kind]
              tokens << [op, :operator]
              next
            end
          elsif match = scan(/[A-Za-z_]+\[[A-Za-z_\d]+\]/)
            # array
            kind = IDENT_KIND(match)
            kind = :instance_variable if kind == :ident
          elsif match = scan(/ \$[A-Za-z_][A-Za-z_0-9]* /ox)
            match =~ /\$(.*)/
            kind = IDENT_KIND[$1]
            kind = :instance_variable if kind == :ident
          elsif match = scan(/read \S+/)
            match =~ /read(\s+)(\S+)/
            tokens << ['read', :method]
            tokens << [$1, :space]
            tokens << [$2, :instance_variable]
            next
          elsif match = scan(/[\!\:\[\]\{\}]/)
            kind = :reserved
          elsif match = scan(/ [A-Za-z_][A-Za-z_\d]*;? /x)
            match =~ /([^;]+);?/
            kind = IDENT_KIND[$1]
            if match[/([^;]+);$/]
              tokens << [$1, kind]
              tokens << [';', :delimiter]
              next
            end
          elsif match = scan(/(?: = | - | \+ | \{ | \} | \( | \) | && | \|\| | ;; | ! )/ox)
            kind = :operator
          elsif match = scan(/\s+/)
            kind = :space
          elsif match = scan(/[^ \$"'`\d]/)
            kind = :plain
          elsif match = scan(/.+/)
            # this shouldn't be :reserved for highlighting bad matches
            match, kind = handle_error(match, options)
          end
        elsif @state == :quote
          if (match = scan(/\\.?/))
            kind = :content
          elsif match = scan(/#{@quote}/)
            tokens << [match, :delimiter]
            tokens << [:close, :string] if @quote == '"'
            tokens << [:close, :shell] if @quote == "`"
            @quote = nil
            @state = :initial
            next
            #kind = :symbol
          elsif match = scan(PRE_CONSTANTS)
            kind = :pre_constant
          elsif match = scan(/ \$\{?[A-Za-z_][A-Za-z_\d]*\}? /x)
            kind = IDENT_KIND[match]
            kind = :instance_variable if kind == :ident
          elsif (@quote == '`') and (match = scan(/\$"/))
            kind = :content
          elsif (@quote == '"') and (match = scan(/\$`/))
            kind = :content
          elsif match = scan(/[^#{@quote}\$\\]+/)
            kind = :content
          else match = scan(/.+/)
            # this shouldn't be
            #kind = :reserved
            #raise match 
            match, kind = handle_error(match, options)
          end
        end
  
        match ||= matched
        tokens << [match, kind]
      end

      tokens
    end
  
  
    def handle_error(match, options)
      o = {:ignore_errors => true}.merge(options)
      if o[:ignore_errors]
        [match, :plain]
      else
        [">>>>>#{match}<<<<<", :error]        
      end
    end

  end
end
end
