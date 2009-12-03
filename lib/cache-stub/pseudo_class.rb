module CacheStub

  private

  class PseudoClass

    @@translator ||= lambda do |metaclass, method|
      @@convertor ||= lambda {|sexp| Ruby2Ruby.new.process(Unifier.new.process(sexp)) }
      @@convertor[ParseTree.translate(metaclass, method)] rescue nil
    end

    def initialize(klass)
      @klass = klass.is_a?(String) ? Object.const_get(klass) : klass
      @metaclass = (class << @klass ; self ; end)
    end

    def id
      @klass.to_s
    end

    def method_code(method)
      @@translator[@metaclass, method]
    end

    def replace_method(method, value_or_code)
      old_method_code = method_code(method)
      new_method_code = "#{value_or_code}" =~ /^def / ?
        value_or_code : %\def #{method}; #{value_or_code.inspect}; end\
      @klass.instance_eval(new_method_code)
      old_method_code
    end

    def remove_method(method)
      @metaclass.send(:remove_method, method) rescue nil
    end

    def replace_methods(&blk)
      (tmp = BlankObject.new).__instance_eval__(&blk)
      methods_in_block = tmp.__methods__ - BlankObject.new.__methods__
      original_method_codes = methods_in_block.inject({}) do |memo, method|
        memo.merge(method => method_code(method))
      end
      @klass.instance_eval(&blk)
      original_method_codes
    end

  end

  class BlankObject
    alias_method :__instance_eval__, :instance_eval
    alias_method :__methods__, :methods
    instance_methods.each {|m| undef_method m unless m =~ /^__.*__$/ }
  end

end
