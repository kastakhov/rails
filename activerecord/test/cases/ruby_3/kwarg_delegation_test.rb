require "cases/helper"
require 'models/topic'
require 'models/reply' # test fails without reply because of STI stuff

class KwargDelegationTest < ActiveRecord::TestCase
  fixtures :topics

  def test_class_methods_with_keyword_args_can_be_called_on_relations
    assert_equal [topics(:second)], Topic.approved.for_author(author_name: 'Mary')
  end
end
