module SubHashChecker
  def sub_hash?(main_hash, sub_hash)
    main_hash.merge(sub_hash) == main_hash
  end
end

module DataModelSingletonMethods
  def data_store(repository = nil)
    if repository
      @repository = repository
    else
      @repository
    end
  end

  def attributes(*attribute_names)
    if attribute_names.empty?
      @attribute_names
    else
      @attribute_names = attribute_names
      @attribute_names << :id
    end
    @attribute_names.each { |attribute| attr_accessor attribute }
  end

  def where(criteria)
    criteria.keys.reject { |key| @attribute_names.include? key }.each do |key|
      raise DataModel::UnknownAttributeError.new(key)
    end

    result = []
    @repository.storage.each do |current_hash|
      current_hash = current_hash[1] if current_hash.is_a? Array
      add_to_result(result, current_hash) if sub_hash?(current_hash, criteria)
    end
    result
  end

  def add_to_result(result, current_hash_informations)
    new_instance = self.new(current_hash_informations)
    new_instance.saved_to_repository = true
    result << new_instance
  end
end

module InitializeHelpers
  def initialize_attributes(names, information_hash)
    names.each do |attribute|
      value = information_hash[attribute]
      if value
        send("#{attribute}=".to_sym, value)
      else
        send("#{attribute}=".to_sym, nil)
      end
    end
  end

  def initialize_singleton_finders(names, which_class)
    names.each do |attribute|
      which_class.define_singleton_method "find_by_#{attribute}".to_sym do |value|
        hash_attribute = {attribute => value}
        which_class.where(hash_attribute)
      end
    end
  end
end

module Helpers
  include SubHashChecker
  include InitializeHelpers

  def find_id_for_instance(instance, repository)
    repository.max_used_id += 1
    @id = repository.max_used_id
    instance[:id] = @id
    repository.create(instance)
    @saved_to_repository = true
  end
end

class HashStore
  include Helpers
  attr_reader :storage
  attr_accessor :max_used_id
  def initialize
    @storage = {}
    @max_used_id = 0
  end

  def create(information_hash)
    id = information_hash[:id]
    @storage[id] = information_hash
  end

  def find(search_hash)
    @storage.values.select do |record|
      sub_hash?(record, search_hash)
    end
  end

  def update(id, to_overload)
    desired_hash = storage[id]
    desired_hash.merge!(to_overload)
  end

  def delete(search_hash)
    find(search_hash).each do |current_hash|
      @storage.delete(current_hash[:id])
    end
  end
end

class ArrayStore
  include Helpers
  attr_reader :storage
  attr_accessor :max_used_id
  def initialize
    @storage = []
    @max_used_id = 0
  end

  def create(information_hash)
    @storage << information_hash
  end

  def find(search_hash)
    @storage.select do |record|
      sub_hash?(record, search_hash)
    end
  end

  def update(id, to_overload)
    index = @storage.find_index { |record| record[:id] == id }

    @storage[index] = to_overload
  end

  def delete(search_hash)
    @storage.reject! { |record| sub_hash? record, search_hash }
  end
end

class DataModel
  include Helpers
  extend Helpers
  extend DataModelSingletonMethods

  class DeleteUnsavedRecordError < RuntimeError; end

  class UnknownAttributeError < ArgumentError
    def initialize(attribute_name)
      super "Unknown attribute #{attribute_name}"
    end
  end
  attr_accessor :saved_to_repository

  def initialize(information_hash = {})
    names = self.class.attributes
    initialize_attributes(names, information_hash)
    @saved_to_repository = false
    initialize_singleton_finders(names, self.class)
  end

  def hash_information
    names = self.class.attributes
    result = {}
    names.each do |attribute|
      result[attribute] = send attribute
    end
    result.delete(:id)
    result
  end

  def save
    instance = hash_information
    if !@saved_to_repository
      find_id_for_instance(instance, data_store)
    else
      data_store.update(data_store.find({id: @id})[0][:id], instance)
    end
    self
  end

  def delete
    if data_store.find(hash_information) == []
      raise DeleteUnsavedRecordError
    else
      data_store.delete(hash_information)
      @saved_to_repository = false
    end
  end

  def ==(other)
    return false unless other.instance_of?(self.class)
    if @saved_to_repository && other.saved_to_repository && id == other.id
      true
    else
      equal?(other)
    end
  end

  private

  def data_store
    self.class.data_store
  end
end
