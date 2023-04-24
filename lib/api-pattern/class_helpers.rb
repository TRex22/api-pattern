# ClassHelpers
# Used to give some of the quality of life methods Rails would usually provide
class Hash
  def with_indifferent_access
    dup.with_indifferent_access!
  end

  def with_indifferent_access!
    keys.each do |key|
      resolve(key)
    end

    self
  end

  def present?
    !blank?
  end

  def blank?
    nil? || self == {}
  end

  private

  def resolve(key)
    if self[key].is_a?(Hash)
      self[key.to_s] = delete(key).with_indifferent_access!
    else
      self[key.to_s] = delete(key)
    end
  end
end

class String
  def present?
    !blank?
  end

  def blank?
    nil? || self == "" || self == ''
  end
end
