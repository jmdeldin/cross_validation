require_relative '../cross_validation'

module CrossValidation

  # Provides a confusion matrix (contingency table) for classification
  # results.
  #
  # See the following book for more details:
  #
  # Speech and Language Processing: An introduction to natural language
  # processing, computational linguistics, and speech recognition. Daniel
  # Jurafsky & James H. Martin.
  class ConfusionMatrix
    # Initialize the confusion matrix with a Proc (or block). This Proc must
    # return a symbol of :tp (true positive), :tn (true negative), :fp (false
    # positive), or :fn (false negative) for a given classification and its
    # expected value.
    #
    # See the unit test for an example Proc.
    #
    # @param [Proc] keys_proc
    def initialize(keys_proc)
      @keys_for = keys_proc
      @values = {:tp => 0, :tn => 0, :fp => 0, :fn => 0}
    end

    [:tp, :tn, :fp, :fn].each do |field|
      define_method(field) { @values.fetch(field) }
    end

    # Save the result of classification
    #
    # @param [Object] actual  The classified value
    # @param [Object] truth   The known, expected value
    # @return [self]
    def store(actual, truth)
      key = @keys_for.call(actual, truth)

      if @values.key?(key)
        @values[key] += 1
      else
        fail IndexError, "#{key} not found in confusion matrix"
      end

      self
    end

    # Computes the accuracy of the classifier, defined as (tp + tn)/n
    #
    # @return [Float]
    def accuracy
      (@values.fetch(:tp) + @values.fetch(:tn)) / total()
    end

    # Computes the precision of the classifier, defined as tp/(tp + fp)
    #
    # @return [Float]
    def precision
      @values.fetch(:tp) / Float(@values.fetch(:tp) + @values.fetch(:fp))
    end

    # Computes the recall of the classifier, defined as tp/(tp + fn)
    #
    # @return [Float]
    def recall
      @values.fetch(:tp) / Float(@values.fetch(:tp) + @values.fetch(:fn))
    end

    # Returns the F-measure of the classifier's precision and recall.
    #
    # @param [Float] beta Favor precision (<1), recall (>1), or both (1)
    # @return [Float]
    def fscore(beta)
      b2 = Float(beta**2)
      ((b2 + 1) * precision * recall) / (b2 * precision + recall)
    end

    # Returns an F-score that favors precision and recall equally.
    #
    # @return [Float]
    def f1
      fscore(1)
    end

    # Returns the classifier's error
    def error
      1.0 - accuracy()
    end

    private

    # Returns the total number of classifications as a Float, since this value
    # is used as a divisor.
    #
    # @return [Float]
    def total
      Float(@values.values.reduce(:+))
    end
  end
end
