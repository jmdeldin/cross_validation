module CrossValidation
  # Provides helper methods for data partitioning.
  #
  module Partitioner

    # Splits the array into +k+-sized subsets.
    #
    # For example, calling this method for the array +%w(foo bar baz qux)+
    # with +k=2+ results in an array of arrays: +[[foo, bar], [baz, qux]]+.
    #
    # @param [Array]  ary    documents to work with
    # @param [Fixnum] k      size of each subset
    # @return [Array]        array of arrays
    # @raise [ArgumentError] if the length of the documents array is not
    #                        evenly divisible by k
    def self.subset(ary, k)
      if ary.length % k != 0
        fail ArgumentError, "Can't create equal subsets when k=#{k}"
      end

      ary.each_slice(k).to_a
    end

    # Returns a flattened copy of the original array without an element at
    # index +i+.
    #
    # @param [Array]  ary  subsets to work with (e.g., array of arrays)
    # @param [Fixnum] i    index to remove
    # @return [Array]
    def self.exclude_index(ary, i)
      ary.rotate(i).drop(1).flatten
    end
  end
end
