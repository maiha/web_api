require File.dirname(__FILE__) + '/test_helper'

class WebApiSimpleTest < Test::Unit::TestCase
  class SearchRequest < WebApi::Request
    parameter :Keyword
    parameter :Version
  end

  def test_query_string
    request  = SearchRequest.new(:keyword=>"name", :version=>1)
    expected = "Keyword=name&Version=1"
    assert_equal expected, request.query_string
  end
end


class WebApiTest < Test::Unit::TestCase
  class SearchRequest < WebApi::Request
    parameter :Keyword        , :optional=>true
    parameter :ResultSet      , :optional=>true
    parameter :CategoryGroup  , :optional=>true
    parameter :SortOrder      , :optional=>true
    parameter :PageNum        , :default=>1
  end

  # Replace this with your real tests.
  def test_parameter_size
    assert_equal 5, SearchRequest.parameters.size
  end

  def test_parameter_for
    assert_equal "keyword",    SearchRequest.parameter_for(:keyword).normalized_name
    assert_equal "result_set", SearchRequest.parameter_for("ResultSet").normalized_name
  end

  def test_parameter_default
    assert_equal 1, SearchRequest.parameter_for(:page_num).default
    assert_equal 1, SearchRequest.parameter_for(:page_num).value
  end

  def test_instance_parameter_for
    request = SearchRequest.new
    assert_equal "keyword",    request.parameter_for(:keyword).normalized_name
    assert_equal "result_set", request.parameter_for("ResultSet").normalized_name
  end

  def test_instance_parameter_default
    request = SearchRequest.new
    assert_equal 1, request.parameter_for(:page_num).default
    assert_equal 1, request.parameter_for(:page_num).value
  end

  def test_instance_overwrite_default
    request = SearchRequest.new(:page_num=>2)
    assert_equal 1, request.parameter_for(:page_num).default
    assert_equal 2, request.parameter_for(:page_num).value
  end

  def test_instance_overwrite_default_by_indifferent_access
    request = SearchRequest.new("PageNum"=>2)
    assert_equal 1, request.parameter_for(:page_num).default
    assert_equal 2, request.parameter_for(:page_num).value
  end

  def test_instance_query_string
    request  = SearchRequest.new(:keyword=>"name", :category_group=>1, "PageNum"=>2)
    expected = "Keyword=name&ResultSet=&CategoryGroup=1&SortOrder=&PageNum=2"
    assert_equal expected, request.query_string
  end

  def test_instance_query_string_with_default
    request  = SearchRequest.new(:keyword=>"name", :category_group=>1)
    expected = "Keyword=name&ResultSet=&CategoryGroup=1&SortOrder=&PageNum=1"
    assert_equal expected, request.query_string
  end

  def test_instance_query_string_with_escaping
    request  = SearchRequest.new(:keyword=>"&=")
    expected = "Keyword=%26%3D&ResultSet=&CategoryGroup=&SortOrder=&PageNum=1"
    assert_equal expected, request.query_string
  end
end

class WebApiInOptionTest < Test::Unit::TestCase
  class SearchRequest < WebApi::Request
    parameter :Keyword
    parameter :ResultSet     , :in=>%w( mini medium )
    parameter :CategoryGroup , :in=>%w( pc ), :default=>"pc"
    parameter :SortOrder     , :in=>%w( pricerank -pricerank daterank popularityrank ), :allow_nil=>true
    parameter :PageNum       , :default=>1
  end

  # Replace this with your real tests.
  def test_invalid_value
    request   = SearchRequest.new
    parameter = request.parameter_for(:ResultSet)
    assert_raises(WebApi::InvalidValue) {parameter.validate}
  end

  def test_valid_value
    request   = SearchRequest.new(:result_set=>"mini")
    parameter = request.parameter_for(:ResultSet)
    assert_nothing_raised {parameter.validate}
  end

  def test_allow_nil_rescue_blanked_value
    request   = SearchRequest.new(:sort_order=>"")
    parameter = request.parameter_for(:sort_order)
    assert_nothing_raised {parameter.validate}
  end

  def test_invalid_value_is_detected_even_if_allow_nil_is_set
    request   = SearchRequest.new(:sort_order=>"test")
    parameter = request.parameter_for(:sort_order)
    assert_raises(WebApi::InvalidValue) {parameter.validate}
  end

  def test_should_not_be_blank
    request   = SearchRequest.new
    parameter = request.parameter_for(:keyword)
    assert_raises(WebApi::InvalidValue) {parameter.validate}
  end

end

class WebApiOptionalOptionTest < Test::Unit::TestCase
  class SearchRequest < WebApi::Request
    parameter :Keyword     , :optional=>true
    parameter :ResultSet
  end

  def test_valid_value
    request   = SearchRequest.new
    parameter = request.parameter_for(:keyword)
    assert_nothing_raised {parameter.validate}
  end

  def test_invalid_value
    request   = SearchRequest.new
    parameter = request.parameter_for(:ResultSet)
    assert_raises(WebApi::InvalidValue) {parameter.validate}
  end
end
