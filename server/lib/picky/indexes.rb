module Picky

  # Holds all indexes and provides operations
  # for extracting and working on them.
  #
  # Forwards a number of operations to the
  # indexes.
  #
  class Indexes

    attr_reader :indexes,
                :index_mapping

    forward :size, :each, :to => :indexes
    each_forward :reindex, :to => :indexes
    instance_forward :clear,
                     :clear_indexes,
                     :register,
                     :reindex,
                     :[],
                     :to_s,
                     :size,
                     :each,
                     :each_category

    def initialize *indexes
      clear_indexes
      indexes.each { |index| register index }
    end

    # Return the Indexes instance.
    #
    def self.instance
      @instance ||= new
    end
    def self.identifier
      name
    end

    # Clears the indexes and the mapping.
    #
    def clear_indexes
      @indexes       = []
      @index_mapping = {}
    end

    # Registers an index with the indexes.
    #
    def register index
      self.indexes << index
      self.index_mapping[index.name] = index
    end
    def self.register index
      self.instance.register index
    end

    # Extracts an index, given its identifier.
    #
    def [] identifier
      index_name = identifier.intern
      index_mapping[index_name] || raise_not_found(index_name)
    end

    # Raises a not found for the index.
    #
    def raise_not_found index_name
      raise %Q{Index "#{index_name}" not found. Possible indexes: "#{indexes.map(&:name).join('", "')}".}
    end

    #
    #
    def to_s
      indexes.indented_to_s
    end

  end

end