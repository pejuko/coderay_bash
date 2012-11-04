# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

$KCODE='UTF8' if RUBY_VERSION < "1.9"

require 'test/unit'
require 'rubygems'
require 'pp'

$current_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift File.expand_path(File.join($current_dir, ".."))

require 'lib/coderay_bash'


class TestErbBash < Test::Unit::TestCase

  def test_0010_ErbBash
    eb_file = File.join($current_dir, "erb_bash.sh")
    assert_equal(
      #["#!/bin/sh", :directive, "\n", :end_line, "\n", :end_line, "perl", :ident, " ", :space, "-", :operator, "e", :ident, "'s/to=5/to=10/'", :string, " ", :space, "/", :plain, "test", :method, "/", :plain, "file", :ident, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Parsed at ", :content, :begin_group, :inline, "<%=", :inline_delimiter, " ", :space, "Time", :constant, ".", :operator, "now", :ident, " ", :space, "%>", :inline_delimiter, :end_group, :inline, "\"", :delimiter, :end_group, :string, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Executed at `Date`", :content, "\"", :delimiter, :end_group, :string, "\n", :end_line, "command", :method, " ", :space, ">>>>>'open quote<<<<<", :error, "\n", :end_line, "other_command", :ident, "\n", :end_line],
      ["#!/bin/sh", :directive, "\n", :end_line, "\n", :end_line, "perl", :ident, " ", :space, "-", :operator, "e", :ident, "'s/to=5/to=10/'", :string, " ", :space, "/", :plain, "test", :method, "/", :plain, "file", :ident, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Parsed at ", :content, :end_group, :string, :begin_group, :inline, "<%=", :inline_delimiter, " ", :space, "Time", :constant, ".", :operator, "now", :ident, " ", :space, "%>", :inline_delimiter, :end_group, :inline, "\"", :delimiter, :end_group, :string, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Executed at `Date`", :content, "\"", :delimiter, :end_group, :string, "\n", :end_line, "command", :method, " ", :space, "'open quote\nother_command\n", :string],
      CodeRay.scan(File.read(eb_file), :erb_bash, :ignore_errors => false).tokens
    )
  end

  def test_0020_ErbBash_Ignoring_Errors
    eb_file = File.join($current_dir, "erb_bash.sh")
    assert_equal(
      #["#!/bin/sh", :directive, "\n", :end_line, "\n", :end_line, "perl", :ident, " ", :space, "-", :operator, "e", :ident, "'s/to=5/to=10/'", :string, " ", :space, "/", :plain, "test", :method, "/", :plain, "file", :ident, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Parsed at ", :content, :begin_group, :inline, "<%=", :inline_delimiter, " ", :space, "Time", :constant, ".", :operator, "now", :ident, " ", :space, "%>", :inline_delimiter, :end_group, :inline, "\"", :delimiter, :end_group, :string, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Executed at `Date`", :content, "\"", :delimiter, :end_group, :string, "\n", :end_line, "command", :method, " ", :space, "'open quote", :plain, "\n", :end_line, "other_command", :ident, "\n", :end_line],
      ["#!/bin/sh", :directive, "\n", :end_line, "\n", :end_line, "perl", :ident, " ", :space, "-", :operator, "e", :ident, "'s/to=5/to=10/'", :string, " ", :space, "/", :plain, "test", :method, "/", :plain, "file", :ident, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Parsed at ", :content, :end_group, :string, :begin_group, :inline, "<%=", :inline_delimiter, " ", :space, "Time", :constant, ".", :operator, "now", :ident, " ", :space, "%>", :inline_delimiter, :end_group, :inline, "\"", :delimiter, :end_group, :string, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "Executed at `Date`", :content, "\"", :delimiter, :end_group, :string, "\n", :end_line, "command", :method, " ", :space, "'open quote\nother_command\n", :string],
      CodeRay.scan(File.read(eb_file), :erb_bash).tokens
    )
  end

  def test_0030_ErbBash_to_html
    eb_file = File.join($current_dir, "function.sh")
    assert_nothing_raised {
      CodeRay.scan(File.read(eb_file), :erb_bash, :ignore_errors => false).html
    }
  end

end


class TestString < Test::Unit::TestCase

  def test_0010_heredoc
    file = File.join($current_dir, "heredoc.sh")
    assert_equal(
      ["#/bin/bash", :comment, "\n", :end_line, "\n", :end_line, "cat", :ident, " ", :space, :begin_group, :string, "<<EOF", :delimiter, "\n", :end_line, "little brown fox jumps over lazy dog\n ", :content, "EOF", :delimiter, :end_group, :string, "\n", :end_line, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "end", :content, "\"", :delimiter, :end_group, :string, "\n", :end_line],
      CodeRay.scan(File.read(file), :bash).tokens
    )
  end

  def test_0020_Comments_in_strings
    eb_file = File.join($current_dir, "string_comment.sh")
    assert_equal(
      ["echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "#output a comment", :content, "\"", :delimiter, :end_group, :string, " ", :space, ">", :bin, " ", :space, "foo", :ident, "\n", :end_line, "echo", :method, " ", :space, :begin_group, :string, "\"", :delimiter, "more", :content, "\"", :delimiter, :end_group, :string, " ", :space, ">", :bin, ">", :bin, " ", :space, "foo", :ident, "  # so this is a comment now", :comment, "\n", :end_line],
      CodeRay.scan(File.read(eb_file), :bash).tokens
    )
  end

end


class TestNested < Test::Unit::TestCase

  def test_0010_nested_shell
    file = File.join($current_dir, "nested_shells.sh")
    assert_equal(
      ["blueberry", :instance_variable, "=", :operator, :begin_group, :shell, "$(", :delimiter, "date", :ident, " ", :space, "-", :operator, "d", :ident, " ", :space, :begin_group, :string, "\"", :delimiter, :begin_group, :shell, "$(", :delimiter, "stat -c ", :content, :begin_group, :shell, "$(", :delimiter, "%z", :content, ")", :delimiter, :end_group, :shell, " blueberry.exe", :content, ")", :delimiter, :end_group, :shell, "\"", :delimiter, :end_group, :string, ")", :delimiter, :end_group, :shell, "\n", :end_line],
      CodeRay.scan(File.read(file), :bash).tokens
    )
  end

end


class TestArray < Test::Unit::TestCase
  
  def test_0010_Array
    eb_file = File.join($current_dir, "json.sh")
    assert_equal(["cat",:ident," ",:space,"$1",:predefined_constant," ",:space,"|",:plain," ",:space,"while",:reserved," ",:space,"read",:method," ",:space,"json;",:instance_variable," ",:space,"do",:reserved," ",:space,"if",:reserved," ",:space,"[",:reserved,"[",:reserved," ",:space,"${",:instance_variable,"array2",:instance_variable,"[",:operator,"0",:key,"]",:operator,"}",:instance_variable," ",:space,"=",:operator,"=",:operator," ",:space,"1",:integer," ",:space,"]",:reserved,"]",:reserved,";",:delimiter," ",:space,"then",:reserved,"\n",:end_line,"echo",:method," ",:space,"$json",:instance_variable," ",:space,"|",:plain," ",:space,"......",:plain,"\n",:end_line],
                 CodeRay.scan(File.read(eb_file), :bash).tokens)
  end

end
