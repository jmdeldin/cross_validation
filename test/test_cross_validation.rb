require_relative 'test_helper'
require_relative '../lib/cross_validation/confusion_matrix'

# A stupid classifier
class SpamClassifier
  def train(klass, document)
    # don't bother, we're that good (in reality, you should probably do some
    # work here)
  end

  def classify(document)
    document =~ /viagra/ ? :spam : :ham
  end
end

# We just need to associate a class with a value. Feel free to use whatever
# data structure you like -- this is only used in user-defined training and
# classifying closures.
Sample = Struct.new(:klass, :value)

class TestCrossValidation < MiniTest::Unit::TestCase
  def setup
    tpl = ['Buy some...', 'Would you like some...']
    @spam = tpl.map { |pfx| Sample.new(:spam, pfx + 'viagra!') }
    @ham = tpl.map { |pfx| Sample.new(:ham, pfx + 'penicillin!') }
    @corpus = @spam + @ham
    @corpus *= 25 # 100 is easier to deal with
  end

  def test_run
    mat = CrossValidation::run(:documents    => @corpus,
                               :folds        => 10,
                               :classifier   => lambda { SpamClassifier.new },
                               :sample_klass => lambda { |sample| sample.klass },
                               :sample_value => lambda { |sample| sample.value },
                               :matrix       => CrossValidation::ConfusionMatrix.new(method(:keys_for)),
                               :training     => lambda { |classifier, doc|
                                 classifier.train doc.klass, doc.value
                               },
                               :classifying  => lambda { |classifier, doc|
                                  classifier.classify doc
                               })
    assert_equal 50, mat.tp
    assert_equal 50, mat.tn
  end
end
