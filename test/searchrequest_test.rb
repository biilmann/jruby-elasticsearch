require File.expand_path('../test_helper', __FILE__)
require 'json'

class SearchRequestTest < Test::Unit::TestCase
  def setup
    @request = ElasticSearch::SearchRequest.new(nil)
  end

  def test_a_string_query
    @request.query("test")
    assert_equal JSON.parse(@request.prep.to_s), {"query"=>{"query_string"=>{"query"=>"test", "default_operator"=>"and"}}}
  end

  def test_a_string_query_with_the_or_operator
    @request.query("test", :or)
    assert_equal({"query"=>{"query_string"=>{"query"=>"test", "default_operator"=>"or"}}}, JSON.parse(@request.prep.to_s))
  end

  def test_a_filter
    @request.filter :term, :project_id => "1"
    assert_equal({"filter"=>{"term"=>{"project_id"=>"1"}}}, JSON.parse(@request.prep.to_s))
  end

  def test_a_filter_and_a_query
    @request.query("test").filter :term, :project_id => "1"
    assert_equal({
        "query"=>{"query_string"=>{"query"=>"test", "default_operator"=>"and"}},
        "filter"=>{"term"=>{"project_id"=>"1"}}
      }, JSON.parse(@request.prep.to_s)
    )
  end

  def test_date_histogram
    @request.date_histogram("created_at", "month")
    assert_equal({
      "facets" => {
        "created_at_month" => {
          "date_histogram" => {
            "field" => "created_at", "interval" => "month"
          }
        }
      }
    }, JSON.parse(@request.prep.to_s))
  end
end
