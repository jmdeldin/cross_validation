# A toy classifier. As long as you can tell the CrossValidation gem how to
# invoke your training and classifying methods, then you can do whatever you
# want in your classifier.
class SpamClassifier
  def train(klass, document)
    # don't bother, we're that good (in reality, you should probably do some
    # work here)
  end

  def classify(document)
    document =~ /viagra/ ? :spam : :ham
  end

  # Dummy method for use in testing confusion matrices. Used to determine
  # whether a class is a true positive|negative or a false positive|negative.
  # This is used when configuring a confusion matrix.
  def self.keys_for(expected, actual)
    if expected == :spam
      actual == :spam ? :tp : :fp
    elsif expected == :ham
      actual == :ham ? :tn : :fn
    end
  end
end
