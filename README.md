# CrossValidation

[![Build Status](https://travis-ci.org/jmdeldin/cross_validation.png?branch=master)](https://travis-ci.org/jmdeldin/cross_validation)
[![Code Climate](https://codeclimate.com/github/jmdeldin/cross_validation.png)](https://codeclimate.com/github/jmdeldin/cross_validation)

This gem provides a k-fold cross-validation routine and confusion matrix
for evaluating machine learning classifiers. See [below](#usage) for
usage or jump to the
[documentation](http://rubydoc.info/github/jmdeldin/cross_validation/frames).

## Installation

Add this line to your application's Gemfile:

    gem 'cross_validation'

And then execute:

    $ bundle install --binstubs .bin

Or install it yourself as:

    $ gem install cross_validation

## Usage

To cross-validate your classifier, you need to configure a run as
follows:

```ruby
require 'cross_validation'

runner = CrossValidation::Runner.create do |r|
  r.documents = my_array_of_documents
  r.folds = 10
  # or if you'd rather test on 10%
  # r.percentage = 0.1
  r.classifier = lambda { SpamClassifier.new }
  r.fetch_sample_class = lambda { |sample| sample.klass }
  r.fetch_sample_value = lambda { |sample| sample.value }
  r.matrix = CrossValidation::ConfusionMatrix.new(method(:keys_for))
  r.training = lambda { |classifier, doc|
    classifier.train doc.klass, doc.value
  }
  r.classifying = lambda { |classifier, doc|
    classifier.classify doc
  }
end
```

With the run configured, just invoke `#run` to return a confusion matrix:

```ruby
mat = runner.run
```

With a confusion matrix in hand, you can compute many statistics about
your classifier:

- `mat.accuracy`
- `mat.f1`
- `mat.fscore(beta)`
- `mat.precision`
- `mat.recall`

Please see the
[respective documentation](http://rubydoc.info/github/jmdeldin/cross_validation/CrossValidation/ConfusionMatrix)
for each method for more details.

## Author

Jon-Michael Deldin, `dev@jmdeldin.com`
