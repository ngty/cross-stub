class AnyClass

  def self.say_world   ; 'u say world' ; end
  def say_hello        ; 'u say hello' ; end

  class Inner
    def self.say_world ; 'u say world' ; end
    def say_hello      ; 'u say hello' ; end
  end

end

module AnyModule

  def self.say_world   ; 'u say world' ; end
  def say_hello        ; 'u say hello' ; end

  module Inner
    def self.say_world ; 'u say world' ; end
    def say_hello      ; 'u say hello' ; end
  end

end
