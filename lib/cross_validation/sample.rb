module CrossValidation
  # Represents a datum and its class (e.g., "spam").
  #
  # This is an optional data structure that simplifies definining training
  # methods in cross-validation runs.
  Sample = Struct.new(:klass, :value)

  # Converts an array of +[class, value]+ into a `Sample` object.
  #
  # @param [Array] tuple
  # @return [Sample]
  def self.Sample(tuple)
    Sample.new(tuple.fetch(0), tuple.fetch(1))
  end
end
