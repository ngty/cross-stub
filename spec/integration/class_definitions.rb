class AnyClass

  def self.say ; 'hello' ; end

  class Inner
    def self.say ; 'hello' ; end
  end

end

class AnyInstance

  def say ; 'hello' ; end

  class Inner
    def say ; 'hello' ; end
  end

end

module AnyModule

  def self.say ; 'hello' ; end

  module Inner
    def self.say ; 'hello' ; end
  end

end
