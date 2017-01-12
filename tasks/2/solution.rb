class Hash
  def fetch_deep(path)
    path.split('.').reduce(self) do |result, key|
      result[key.to_i] || result[key.to_sym] || result[key.to_s] if result
    end
  end

  def reshape(shape)
    shape.map do |key, shape|
      shape.is_a?(String) ? [key, fetch_deep(shape)] : [key, reshape(shape)]
    end.to_h
  end
end

class Array
  def reshape(shape)
    map { |value| value.reshape(shape) }
  end
end
