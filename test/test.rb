# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

$KCODE='UTF8'

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
    assert_equal( CodeRay.scan(File.read(eb_file), :erb_bash),
[["#!/bin/sh", :directive],
 ["\n", :end_line],
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
 ["\n", :end_line]]
    )
  end
end
