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

    # @return [Fixnum] The number of folds to partition +documents+ into as a
    #                  *percentage* of the documents. Mutually exclusive with
    #                  +folds+.
    # TODO: Implement
    attr_accessor :percentage

    # @return [ConfusionMatrix]
    attr_accessor :matrix

    # @return [Proc] This receives an instantiated +classifier+ and a
    #                document, and it should call your classifier's training
    #                method.
    attr_accessor :training

    # @return [Proc] This receives a *trained* classifier and a test document.
    #                It classifies the document.
    attr_accessor :classifying

    # @return [Proc] This receives a document and should return its value,
    #                i.e., whatever you're feeding into +classifying+.
    attr_accessor :fetch_sample_value

    # @return [Proc] When verifying the results of executing the +classifying+
    #                method, we need to determine what the actual class (e.g.,
    #                spam) of the document was. This +Proc+ receives a
    #                document and should return the document's class.
    attr_accessor :fetch_sample_class

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
    def self.run(options)
      documents = options.documents
      folds = options.folds
      classifier_proc = options.classifier
      training_proc = options.training
      classifying_proc = options.classifying
      confusion = options.matrix
      sample_klass = options.fetch_sample_class
      sample_value = options.fetch_sample_value

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

    # Configuring a cross-validation run is complicated. Let's make it easier
    # with a factory method.
    def self.create
      new.tap { |r| yield(r) }
    end
  end
end
