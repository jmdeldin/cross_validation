require 'minitest/autorun'

# Dummy method for use in testing confusion matrices.
def keys_for(actual, expected)
  if actual == :spam
    expected == :spam ? :tp : :fn
  elsif actual == :ham
    expected == :ham ? :tn : :fp
  end
end
