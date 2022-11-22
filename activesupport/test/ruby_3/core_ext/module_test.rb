require 'abstract_unit'

class KeywordMethodsClass
  def keyword_method(*args, kwarg: 'default-kwarg')
    [args, kwarg]
  end
end

KeywordMethodTester = Struct.new(:target) do
  delegate :keyword_method, to: :target
end

class ModuleTest < Test::Unit::TestCase
  def test_keyword_method_delegation
    keyword_tester = KeywordMethodTester.new(KeywordMethodsClass.new)

    assert_equal [[:foo, :bar], :baz], keyword_tester.keyword_method(:foo, :bar, kwarg: :baz)
  end
end
