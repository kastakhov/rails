require 'cases/helper'
require 'models/topic'
require 'models/reply'
require 'models/post'

module SharedSerializedAttributeTests
  MyObject = Struct.new :attribute1, :attribute2

  def teardown
    Topic.serialize("content")
  end

  def test_serialized_attribute
    Topic.serialize("content", MyObject)

    myobj = MyObject.new('value1', 'value2')
    topic = Topic.create("content" => myobj)
    assert_equal(myobj, topic.content)

    topic.reload
    assert_equal(myobj, topic.content)
  end

  def test_serialized_time_attribute
    myobj = Time.local(2008,1,1,1,0)
    topic = Topic.create("content" => myobj).reload
    assert_equal(myobj, topic.content)
  end

  def test_serialized_string_attribute
    myobj = "Yes"
    topic = Topic.create("content" => myobj).reload
    assert_equal(myobj, topic.content)
  end

  def test_nil_serialized_attribute_with_class_constraint
    myobj = MyObject.new('value1', 'value2')
    topic = Topic.new
    assert_nil topic.content
  end

  def test_should_raise_exception_on_assigning_already_serialized_content
    topic = Topic.new
    serialized_content = %w[foo bar].to_yaml
    assert_raise(ActiveRecord::ActiveRecordError) { topic.content = serialized_content }
  end

  def test_should_raise_exception_on_serialized_attribute_with_type_mismatch
    myobj = MyObject.new('value1', 'value2')
    topic = Topic.new(:content => myobj)
    assert topic.save
    Topic.serialize(:content, Hash)
    assert_raise(ActiveRecord::SerializationTypeMismatch) { Topic.find(topic.id).content }
  ensure
    Topic.serialize(:content)
  end

  def test_serialized_attribute_with_class_constraint
    settings = { "color" => "blue" }
    Topic.serialize(:content, Hash)
    topic = Topic.new(:content => settings)
    assert topic.save
    assert_equal(settings, Topic.find(topic.id).content)
  ensure
    Topic.serialize(:content)
  end
end

class SerializedAttributeTest < ActiveRecord::TestCase
  def setup
    ActiveRecord::Base.use_yaml_unsafe_load = true
  end

  include SharedSerializedAttributeTests
end

class SerializedAttributeTestWithYAMLSafeLoad < ActiveRecord::TestCase
  def setup
    ActiveRecord::Base.use_yaml_unsafe_load = false
  end

  include SharedSerializedAttributeTests

  def test_should_raise_exception_on_serialized_attribute_with_type_mismatch
    myobj = String.new("value1")
    topic = Topic.new(content: myobj)
    assert topic.save
    Topic.serialize(:content, Hash)
    assert_raise(ActiveRecord::SerializationTypeMismatch) { Topic.find(topic.id).content }
  end

  def test_serialized_attribute
    Topic.serialize("content", String)

    myobj = String.new("value1")
    topic = Topic.create("content" => myobj)
    assert_equal(myobj, topic.content)

    topic.reload
    assert_equal(myobj, topic.content)
  end

  def test_unpermitted_classes_are_not_deserialized
    Topic.serialize("content")

    topic = Topic.create("content" => { "foo" => Time.now })

    assert_raise(Psych::DisallowedClass) do
      begin
        topic.reload.content
      rescue Exception => e
        assert_equal 'Tried to load unspecified class: Time', e.message
        raise
      end
    end
  end

  def test_unknown_classes_are_not_deserialized
    Topic.serialize("content")

    topic = Topic.create
    Topic.update_all("content" => "--- !ruby/object:DoesNotExist {}\n")

    assert_raise(Psych::DisallowedClass) do
      begin
        topic.reload.content
      rescue Exception => e
        assert_equal 'Tried to load unspecified class: DoesNotExist', e.message
        raise
      end
    end
  end

  def test_permitted_classes_are_serialized
    yaml_column_permitted_classes_default = ActiveRecord::Base.yaml_column_permitted_classes
    ActiveRecord::Base.yaml_column_permitted_classes = [Time]

    Topic.serialize("content")

    t = Time.now
    topic = Topic.create("content" => { "foo" => t })
    assert_equal t, topic.reload.content['foo']
  ensure
    ActiveRecord::Base.yaml_column_permitted_classes = yaml_column_permitted_classes_default
  end

  def test_serialized_time_attribute
    skip "Time is not a supported class in Psych::safe_load."
    # skip; Time is not a supported class in Psych::safe_load.
  end
end
