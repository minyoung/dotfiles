class Object
  # returns a list of methods, not including those inherited from Object
  def local_methods
    is_instance = [Class, Module].include?(self.class) ? false : true
    ((is_instance ? methods : instance_methods) - Object.methods).sort
  end

  # returns a list of all modules in the current object
  def modules
    klass = [Class, Module].include?(self.class) ? self : self.class
    klass.constants.find_all { |item| klass.const_get(item).class == Module }.sort
  end

  # returns a list of all the classes in the current object
  def classes
    klass = [Class, Module].include?(self.class) ? self : self.class
    klass.constants.find_all { |item| klass.const_get(item).class == Class }.sort
  end
end

# vim: set ft=ruby :
