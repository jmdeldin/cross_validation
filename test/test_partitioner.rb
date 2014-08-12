require_relative 'test_helper'
require_relative '../lib/cross_validation/partitioner'

class TestPartitioner < Minitest::Test
  def setup
    @docs = %w(foo bar baz qux)
    @p    = CrossValidation::Partitioner
  end

  def test_create_equal_subsets_returns_equal_subsets
    subsets = @p.subset(@docs, 2)

    assert_equal %w(foo bar), subsets.first
    assert_equal %w(baz qux), subsets.last
  end

  def test_create_equal_subsets_prevents_unequal_subsets
    e = assert_raises ArgumentError do
      @p.subset(@docs, 3)
    end
    assert_equal "Can't create equal subsets when k=3", e.message
  end

  def test_exclude_by_index
    samples = @p.exclude_index(@docs, 1)
    assert_equal %w(baz qux foo), samples
  end
end
