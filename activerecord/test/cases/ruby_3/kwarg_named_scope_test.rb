require "cases/helper"
require 'models/topic'
require 'models/reply' # test fails without reply because of STI stuff

class KwargNamedScopeTest < ActiveRecord::TestCase
  fixtures :topics

  def test_procedural_scopes_work_with_keyword_arguments
    topics_written_before_the_third = Topic.find(:all, :conditions => ['written_on < ?', topics(:third).written_on])

    assert_equal topics_written_before_the_third, Topic.written(before: topics(:third).written_on)
  end
end
