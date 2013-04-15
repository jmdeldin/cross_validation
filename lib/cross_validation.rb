$LOAD_PATH.unshift File.dirname(__FILE__)

module CrossValidation
  VERSION = '0.0.2'
end

%w(confusion_matrix runner).each do |fn|
  require File.join('cross_validation', fn)
end
