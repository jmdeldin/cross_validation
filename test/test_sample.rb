require_relative 'test_helper'
require_relative '../lib/cross_validation/sample'

class TestSample < MiniTest::Unit::TestCase
  def setup
    @sample = CrossValidation::Sample.new(:spam, :spammy_msg)
  end

  def test_klass
    assert_equal :spam, @sample.klass
  end

  def test_value
    assert_equal :spammy_msg, @sample.value
  end

  def test_casting_a_tuple_to_sample
    tuple = [:ham, :some_value]
    sample = CrossValidation::Sample(tuple)
    assert_equal :ham, sample.klass
    assert_equal :some_value, sample.value
  end

  def test_casting_an_incomplete_tuple_to_sample_fails
    assert_raises IndexError do
      CrossValidation::Sample([])
    end
  end
end
