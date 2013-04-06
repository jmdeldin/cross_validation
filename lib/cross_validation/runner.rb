require_relative '../cross_validation'

module CrossValidation
  class Runner
    # @return [Array] Array of documents to train and test on. It can be an
    #                 array of anything, as the +fetch_sample_value+ and
    #                 +fetch_sample_class+ lambdas specify what to feed into
    #                 the classifying method.
    attr_accessor :documents

    # @return [Proc] This instantiates your classifier.
    attr_accessor :classifier

    # @return [Fixnum] The number of folds to partition +documents+ into.
    #                  Mutually exclusive with +percentage+.
    attr_accessor :folds

    # @return [Float] The number of folds to partition +documents+ into as a
    #                 *percentage* of the documents. Mutually exclusive with
    #                 +folds+.
    attr_accessor :percentage

    # @return [ConfusionMatrix]
    attr_accessor :matrix

    # @return [Proc] This receives an instantiated +classifier+ and a
    #                document, and it should call your classifier's training
    #                method.
    attr_accessor :training

    # @return [Proc] This receives a *trained* classifier and a test document.
    #                It classifies the document. It's a +Proc+ because we
    #                create a new one with each partition.
    attr_accessor :classifying

    # @return [Proc] This receives a document and should return its value,
    #                i.e., whatever you're feeding into +classifying+.
    attr_accessor :fetch_sample_value

    # @return [Proc] When verifying the results of executing the +classifying+
    #                method, we need to determine what the actual class (e.g.,
    #                spam) of the document was. This +Proc+ receives a
    #                document and should return the document's class.
    attr_accessor :fetch_sample_class

    # Returns the number of folds to partition the documents into.
    #
    # @return [Fixnum]
    def k
      @k ||= percentage ? (documents.size * percentage) : folds
    end

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
    def run
      partitions = documents.each_slice(k).to_a

      results = partitions.map.with_index do |part, i|
        # Array#rotate puts the element i first, so all we have to do is rotate
        # then remove that element to get the training set. Array#drop does not
        # mutate the original array either. Array#flatten is needed to coalesce
        # our list of lists into one list again.
        training_samples = partitions.rotate(i).drop(1).flatten

        classifier_instance = classifier.call()

        # train it
        training_samples.each { |doc| training.call(classifier_instance, doc) }

        # fetch confusion keys
        part.each do |x|
          prediction = classifying.call(classifier_instance, fetch_sample_value.call(x))
          matrix.store(prediction, fetch_sample_class.call(x))
        end
      end

      matrix
    end

    # Configuring a cross-validation run is complicated. Let's make it easier
    # with a factory method.
    def self.create
      new.tap { |r| yield(r) }
    end
  end
end
