require 'enumerator'

class Platform
  def self.get_subclasses
    ObjectSpace.enum_for(:each_object, class << self; self; end).to_a - [self]
  end
end