require_relative 'test_helper'
require_relative 'support/spam_classifier'
require_relative '../lib/cross_validation/confusion_matrix'
require_relative '../lib/cross_validation/sample'
require_relative '../lib/cross_validation/runner'

# Asserts the DSL's getter and setters work.
def check_dsl(attribute, value)
  runner = CrossValidation::Runner.create { |r|
    r.public_send("#{attribute}=", :value)
  }

  define_method("test_#{attribute}_getter") {
    assert_equal :value, runner.public_send(attribute)
  }

  define_method("test_runner_is_invalid_with_only_#{attribute}_set") {
    assert runner.invalid?
  }
end

class TestRunner < MiniTest::Unit::TestCase
  def setup
    tpl = ['Buy some...', 'Would you like some...']
    @spam = tpl.map { |pfx| CrossValidation::Sample.new(:spam, pfx + 'viagra!') }
    @ham = tpl.map { |pfx| CrossValidation::Sample.new(:ham, pfx + 'penicillin!') }
    @corpus = @spam + @ham
    @corpus *= 25 # 100 is easier to deal with
  end

  def test_run
    runner = CrossValidation::Runner.create do |r|
      r.documents = @corpus
      r.folds = 10
      r.classifier = lambda { SpamClassifier.new }
      r.matrix = CrossValidation::ConfusionMatrix.new(SpamClassifier.method(:keys_for))
      r.training = lambda { |classifier, doc|
        classifier.train doc.klass, doc.value
      }
      r.classifying = lambda { |classifier, doc|
        classifier.classify doc
      }
    end

    mat = runner.run

    assert_equal 50, mat.tp
    assert_equal 50, mat.tn
  end

  def test_percentage_takes_precedence_over_folds
    runner = CrossValidation::Runner.create do |r|
      r.documents = ['foo'] * 100
      r.folds = 20
      r.percentage = 0.1
    end

    assert_equal 10, runner.k
  end

  [
   :documents,
   :folds,
   :classifier,
   :fetch_sample_value,
   :fetch_sample_class,
   :matrix,
   :training,
   :classifying,
  ].each do |attribute|
    check_dsl(attribute, :foo)
  end
end
