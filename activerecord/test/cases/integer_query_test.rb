require 'cases/helper'
require 'models/edge'
# TODO
# require 'models/minivan'
require 'models/person'
require 'models/post'

# require 'active_support/core_ext/big_decimal'


module MysqlIntegerComparisonTests
  def test_where_with_integer
    person = Person.create!(:first_name => 'Alice', :primary_contact_id => 5)
    assert_equal person, Person.scoped(:conditions => { :primary_contact_id => 5 }).first
  end

  def test_where_with_boolean_on_incorrect_column
    Person.destroy_all
    true_person = Person.create!(:first_name => true)
    false_person = Person.create!(:first_name => false)
    assert_equal true_person, Person.scoped(:conditions => { :first_name => true }).first
    assert_equal false_person, Person.scoped(:conditions => { :first_name => false }).first
  end

  def test_where_with_integer_for_string_column
    assert_only_raises_on_postgres do
      count = Post.scoped(:conditions => { :title => 0 }).count
      if expect_integer_bug?
        assert_equal Post.count, count
      else
        assert_equal 0, count
      end
    end
  end

  def test_where_with_integer_for_missing_table
    assert_only_raises_on_postgres do
      Post.scoped(:from => 'posts AS ps', :conditions => { 'ps.title' => 0 }).count
    end
  end

  def test_where_with_float_for_string_column
    assert_only_raises_on_postgres do
      count = Post.scoped(:conditions => { :title => 0.0 }).count
      if expect_integer_bug?
        assert_equal Post.count, count
      else
        assert_equal 0, count
      end
    end
  end

  def test_where_with_boolean_for_string_column
    count = Post.scoped(:conditions => { :title => false }).count
    if expect_integer_bug?
      assert_equal Post.count, count
    else
      assert_equal 0, count
    end
  end

  def test_where_with_decimal_for_string_column
    assert_only_raises_on_postgres do
      count = Post.scoped(:conditions => { :title => BigDecimal.new('0') }).count
      if expect_integer_bug?
        assert_equal Post.count, count
      else
        assert_equal 0, count
      end
    end
  end

  def test_construct_finder_sql_does_not_crash_on_integer_conditions_on_join_tables
    assert_nothing_raised do
      Person.scoped(:joins => :agents, :conditions => { 'agents_people.primary_contact_id' => 0 }).count
    end
  end

  def test_scope_with_static_where_conditions
    assert_nothing_raised do
      Class.new(ActiveRecord::Base) do
        self.table_name = "missing_table"
        named_scope :id_0, :conditions => { :id => 0 }
      end
    end
  end

  def test_create_scope
    scope = Person.scoped(:conditions => { :first_name => 1 })
    person = scope.new
    assert_equal 1, person.first_name
  end


  private

  def assert_only_raises_on_postgres(&block)
    if current_adapter?(:PostgreSQLAdapter)
      assert_raises(ActiveRecord::StatementInvalid, &block)
    else
      assert_nothing_raised(&block)
    end
  end
end

class MysqlIntegerComparisonWithoutCastingTest < ActiveRecord::TestCase
  fixtures :posts

  include MysqlIntegerComparisonTests

  private

  def expect_integer_bug?
    current_adapter?(:MysqlAdapter) || current_adapter?(:Mysql2Adapter)
  end
end

class MysqlIntegerComparisonWithCastingTest < ActiveRecord::TestCase
  fixtures :posts

  def setup
    @old_configuration = RailsLts.configuration
    RailsLts.configuration = RailsLts::Configuration.new(:cast_integers_on_mysql_string_columns => true)
  end

  def teardown
    RailsLts.configuration = @old_configuration
  end

  include MysqlIntegerComparisonTests

  private

  def expect_integer_bug?
    false
  end
end
