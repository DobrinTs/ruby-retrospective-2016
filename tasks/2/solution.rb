def put_in_result(result, current_key)
  if result.is_a? Array
    result[current_key.to_i]
  elsif result.is_a? Hash
    result[current_key] || result[current_key.to_sym]
  else
    nil
  end
end

class Hash
  def fetch_deep(path)
    keys = path.split('.')
    return nil if keys.empty?
    return nil unless result = self[keys[0]] || self[keys[0].to_sym]
    keys[1..-1].each do |current_key|
      result = put_in_result(result, current_key)
    end
    result
  end

  def reshape(shape)
    new_hash = {}
    shape.each do |key, path|
      take_value_or_use_recursion(key, path, new_hash, self)
    end
    new_hash
  end
end

def take_value_or_use_recursion(key, path, new_hash, old_hash)
  if path.is_a? String
    new_hash[key] = old_hash.fetch_deep(path)
  elsif path.is_a? Hash
    new_hash[key] = old_hash.reshape(path)
  end
end

class Array
  def reshape(shape)
    new_arr = []
    self.each { |hash_element| new_arr.push hash_element.reshape(shape) }
    new_arr
  end
end
