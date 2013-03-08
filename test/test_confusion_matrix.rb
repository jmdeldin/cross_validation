require_relative 'test_helper'
require_relative '../lib/cross_validation/confusion_matrix'

# A stupid classifier
def classify(document)
  tokens = document.split(' ')
  tokens.include?('viagra') ? :spam : :ham
end

def keys_for(actual, expected)
  if actual == :spam
    expected == :spam ? :tp : :fn
  elsif actual == :ham
    expected == :ham ? :tn : :fp
  end
end

class TestConfusionMatrix < MiniTest::Unit::TestCase
  def delta
    1e-6
  end

  def setup
    tpl = ['Buy some...', 'Would you like some...']
    @spam = tpl.map { |pfx| pfx + 'viagra!' }
    @ham = tpl.map { |pfx| pfx + 'penicillin!' }
    @corpus = @spam + @ham

    @mat = CrossValidation::ConfusionMatrix.new(method(:keys_for))
  end

  def test_true_positives
    true_positive(@mat)
    assert_equal 1, @mat.tp
  end

  def test_true_negatives
    true_negative(@mat)
    assert_equal 1, @mat.tn
  end

  def test_false_positives
    false_positive(@mat)
    assert_equal 1, @mat.fp
  end

  def test_false_negatives
    false_negative(@mat)
    assert_equal 1, @mat.fn
  end

  def test_store_raises_index_error_on_bad_key
    bad_keys_for = ->(actual, expected) { :bad }
    mat = CrossValidation::ConfusionMatrix.new(bad_keys_for)
    assert_raises IndexError do
      mat.store(:ham, :spam)
    end
  end

  def test_accuracy
    true_positive(@mat)
    true_negative(@mat)
    false_negative(@mat)

    assert_in_delta 2.0/3.0, @mat.accuracy, delta
  end

  def test_precision
    true_positive(@mat)
    false_positive(@mat)

    assert_in_delta 0.5, @mat.precision, delta
  end

  def test_error
    true_positive(@mat)
    true_negative(@mat)
    false_positive(@mat)

    assert_in_delta 1/3.0, @mat.error, delta
  end

  def test_precision
    true_positive(@mat)
    false_positive(@mat)
    false_positive(@mat)
    false_positive(@mat)

    assert_in_delta 0.25, @mat.precision, delta
  end

  def test_recall
    true_positive(@mat)
    false_negative(@mat)

    assert_in_delta 0.5, @mat.recall, delta
  end

  def test_fscore
    true_positive(@mat)
    true_negative(@mat)
    false_positive(@mat)

    assert_in_delta 2/3.0, @mat.fscore(1), delta
  end

  def test_f1score
    true_positive(@mat)
    true_negative(@mat)

    assert_in_delta 1.0, @mat.f1, delta
  end

  private

  def true_positive(mat)  mat.store(:spam, :spam) end
  def true_negative(mat)  mat.store(:ham, :ham)   end
  def false_positive(mat) mat.store(:ham, :spam)  end
  def false_negative(mat) mat.store(:spam, :ham)  end
end
