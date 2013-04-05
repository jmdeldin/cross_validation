$LOAD_PATH.unshift File.dirname(__FILE__)

module CrossValidation
  VERSION = '0.0.1'

  # Performs k-fold cross-validation and returns a confusion matrix.
  #
  # The algorithm is as follows (Mitchell, 1997, p147):
  #
  #   partitions = partition data into k-equal sized subsets (folds)
  #   for i = 1 -> k:
  #     T = data \ partitions[i]
  #     train(T)
  #     classify(partitions[i])
  #   output confusion matrix
  #
  # k = number of folds as a percentage (e.g., 10 == 10% of data is used for testing)
  def self.run(options)
    documents = options.fetch(:documents)
    folds = options.fetch(:folds, 10)
    classifier_proc = options.fetch(:classifier)
    training_proc = options.fetch(:training)
    classifying_proc = options.fetch(:classifying)
    confusion = options.fetch(:matrix)
    sample_klass = options.fetch(:sample_klass)
    sample_value = options.fetch(:sample_value)

    k = documents.size / folds
    partitions = documents.each_slice(k).to_a

    results = partitions.map.with_index do |part, i|
      # Array#rotate puts the element i first, so all we have to do is rotate
      # then remove that element to get the training set. Array#drop does not
      # mutate the original array either. Array#flatten is needed to coalesce
      # our list of lists into one list again.
      training = partitions.rotate(i).drop(1).flatten

      # setup a new classifier
      classifier = classifier_proc.call()

      # train it
      training.each { |doc| training_proc.call(classifier, doc) }

      # fetch confusion keys
      part.each do |x|
        prediction = classifying_proc.call(classifier, sample_value.call(x))
        confusion.store(prediction, sample_klass.call(x))
      end
    end

    confusion
  end
end
