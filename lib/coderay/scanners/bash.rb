# Scanner for Bash
# Author: Petr Kovar <pejuko@gmail.com>
module CodeRay::Scanners
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

    RESERVED = RESERVED_WORDS + COMMANDS + BASH_COMMANDS

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

    CONSTANTS = VARIABLES + BASH_VARIABLES

    def scan_tokens tokens, options

      state = :initial
      quote = nil

      until eos?
        kind = match = nil

        if match = scan(/\n/)
          tokens << [match, :end_line]
          next
        end

        if state == :initial
          if match = scan(/#.*/)
            kind = :comment
          elsif match = scan(/(?:\. |source ).*/)
            kind = :reserved
          elsif match = scan(/(?:\\.|,)/)
            kind = :plain
          elsif match = scan(/;/)
            kind = :delimiter
          elsif match = scan(/(?:"|`)/)
            state = :quote
            quote = match
            tokens << [match, :plain]
            tokens << [:open, :string] if quote == '"'
            tokens << [:open, :shell] if quote == '`'
            next
          elsif match = scan(/'[^']*'/)
            kind = :string
          elsif match = scan(/(?: \& | > | < | \| >> | << | >\& )/ox)
            kind = :bin
          elsif match = scan(/\d+\.(?:\d+\.?)+/)
            #version
            kind = :float
          elsif match = scan(/\d+\.\d+\s+/)
            kind = :float
          elsif match = scan(/\d+/)
            kind = :integer
          elsif match = scan(/ (?: \$\(\( | \)\) ) /x)
            kind = :global_variable
          elsif match = scan(/ \$\{ [^\}]+ \} /ox)
            kind = :instance_variable
            match =~ /\$\{(.*)\}/
            kind = :pre_type if CONSTANTS.include?($1)
          elsif match = scan(/ \$\( [^\)]+ \) /ox)
            kind = :shell
          elsif match = scan(/ \$\{? (?: \# | \? | \d | \* | @ | - | \$ | \! | _ ) \}? /ox)
            kind = :pre_constant
          elsif match = scan(/[^\s]*[A-Za-z_][A-Za-z_0-9]*\+?=/)
            match =~ /(.*?)([A-Za-z_][A-Za-z_0-9]*)(\+?=)/
            str = $1
            pre = $2
            op = $3
            kind = :plain
            if str.to_s.strip.empty?
              kind = :instance_variable
              kind = :pre_type if CONSTANTS.include?(pre)
              #kind = :pre_constant if CONSTANTS.include?(pre)
              tokens << [pre, kind]
              tokens << [op, :operator]
              next
            end
          elsif match = scan(/[A-Za-z_]+\[[A-Za-z_\d]+\]/)
            # array
            kind = :instance_variable
            kind = :pre_type if CONSTANTS.include?(match)
          elsif match = scan(/ \$[A-Za-z_][A-Za-z_0-9]* /ox)
            kind = :instance_variable
            match =~ /\$(.*)/
            kind = :pre_type if CONSTANTS.include?($1)
          elsif match = scan(/read \S+/)
            match =~ /read(\s+)(\S+)/
            tokens << ['read', :reserved]
            tokens << [$1, :space]
            tokens << [$2, :instance_variable]
            next
          elsif match = scan(/[\!\:\[\]\{\}]/)
            kind = :reserved
          elsif match = scan(/ [A-Za-z_][A-Za-z_\d]*;? /x)
            match =~ /([^;]+);?/
            if RESERVED.include?($1)
              if match[/([^;]+);$/]
                tokens << [$1, :reserved]
                tokens << [';', :delimiter]
                next
              end
              kind = :reserved
            end
          elsif match = scan(/(?: = | - | \+ | \{ | \} | \( | \) | && | \|\| | ;; | ! )/ox)
            kind = :operator
          elsif match = scan(/\s+/)
            kind = :space
          elsif match = scan(/[^ \$"'`\d]/)
            kind = :plain
          elsif match = scan(/.+/)
            # this shouldn't be
            kind = :reserved
          end
        elsif state == :quote
          if (match = scan(/\\./))
            kind = :content
          elsif match = scan(/#{quote}/)
            tokens << [:close, :string] if quote == '"'
            tokens << [:close, :shell] if quote == "`"
            quote = nil
            state = :initial
            kind = :plain
          elsif match = scan(/ (?: \$\{?[A-Za-z_][A-Za-z_\d]*\}? | \$\{?(?:\#|\?|\d)\}? ) /x)
            kind = :instance_variable
          elsif (quote == '`') and (match = scan(/\$"/))
            kind = :content
          elsif (quote == '"') and (match = scan(/\$`/))
            kind = :content
          elsif match = scan(/[^#{quote}\$\\]+/)
            kind = :content
          else match = scan(/.+/)
            # this shouldn't be
            kind = :reserved
          end
        end
  
        match ||= matched
        tokens << [match, kind]
      end

      tokens
    end

  end
end
