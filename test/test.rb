# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

$KCODE='UTF8' if RUBY_VERSION < "1.9"

require 'test/unit'
require 'rubygems'
require 'pp'

$current_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift File.expand_path(File.join($current_dir, ".."))

require 'coderay'
require 'lib/coderay_bash'

class TestErbBash < Test::Unit::TestCase
  def test_0010_ErbBash
    eb_file = File.join($current_dir, "erb_bash.sh")
    assert_equal(
        [["#!/bin/sh", :directive],
         ["\n", :end_line],
         ["\n", :end_line],
         ["perl", :ident],
         [" ", :space],
         ["-", :operator],
         ["e", :ident],
         ["'s/to=5/to=10/'", :string],
         [" ", :space],
         ["/", :plain],
         ["test", :method],
         ["/", :plain],
         ["file", :ident],
         ["\n", :end_line],
         ["echo", :method],
         [" ", :space],
         [:open, :string],
         ["\"", :delimiter],
         ["Parsed at ", :content],
         [:open, :inline],
         ["<%=", :inline_delimiter],
         [" ", :space],
         ["Time", :constant],
         [".", :operator],
         ["now", :ident],
         [" ", :space],
         ["%>", :inline_delimiter],
         [:close, :inline],
         ["\"", :delimiter],
         [:close, :string],
         ["\n", :end_line],
         ["echo", :method],
         [" ", :space],
         [:open, :string],
         ["\"", :delimiter],
         ["Executed at `Date`", :content],
         ["\"", :delimiter],
         [:close, :string],
         ["\n", :end_line],
         ["command", :method],
         [" ", :space],
         [">>>>>'open quote<<<<<", :error],
         ["\n", :end_line], 
         ["other_command", :ident],
         ["\n", :end_line]
         ],
         CodeRay.scan(File.read(eb_file), :erb_bash, :ignore_errors => false))
  end

  def test_0011_ErbBash_Ignoring_Errors
    eb_file = File.join($current_dir, "erb_bash.sh")
    assert_equal( 
        [["#!/bin/sh", :directive],
         ["\n", :end_line],
         ["\n", :end_line],
         ["perl", :ident],
         [" ", :space],
         ["-", :operator],
         ["e", :ident],
         ["'s/to=5/to=10/'", :string],
         [" ", :space],
         ["/", :plain],
         ["test", :method],
         ["/", :plain],
         ["file", :ident],
         ["\n", :end_line],
         ["echo", :method],
         [" ", :space],
         [:open, :string],
         ["\"", :delimiter],
         ["Parsed at ", :content],
         [:open, :inline],
         ["<%=", :inline_delimiter],
         [" ", :space],
         ["Time", :constant],
         [".", :operator],
         ["now", :ident],
         [" ", :space],
         ["%>", :inline_delimiter],
         [:close, :inline],
         ["\"", :delimiter],
         [:close, :string],
         ["\n", :end_line],
         ["echo", :method],
         [" ", :space],
         [:open, :string],
         ["\"", :delimiter],
         ["Executed at `Date`", :content],
         ["\"", :delimiter],
         [:close, :string],
         ["\n", :end_line],
         ["command", :method],
         [" ", :space],
         ["'open quote", :plain],
         ["\n", :end_line],
         ["other_command", :ident],
         ["\n", :end_line]
         ],
        CodeRay.scan(File.read(eb_file), :erb_bash))
  end

end
