require File.dirname(__FILE__) + '/test_helper'

require 'rubygems'
require 'scrapi'
require 'pp'

$KCODE = 'u'

class ScraperTest < Test::Unit::TestCase
  class ScrapeName < Scraper::Base
    selector :select_name, ".name"

    process "div" do |tag|
      p [:class, tag.class]      # [:class, HTML::Tag]
      p [:name,  tag.name]       # [:name,  "div"]
      p [:to_s,  tag.to_s]       # [:to_s,  "<div>&#33310;&#27874;</div>"]
#      p [:children, tag.children.first]
      p [:content, tag.children.first.content]
#      p [:content, tag.content]
      p (tag.methods - tag.class.superclass.superclass.instance_methods).sort
    end
  end

  def test_scrap
    html = "<DIV>舞波</DIV>"
    ScrapeName.scrape(html, :parser_options => {:char_encoding=>'utf8'})
  end
end

