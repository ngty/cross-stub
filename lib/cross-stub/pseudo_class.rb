module CrossStub

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
      status = backup_method(method)
      @klass.instance_eval "#{value_or_code}" =~ /^def / ? value_or_code :
          %\def #{method}; Marshal.load(%|#{Marshal.dump(value_or_code)}|) ; end\
      status
    end

    def revert_method(method)
      new_name = before_stubbing_method_name(method)
      @metaclass.instance_eval("alias_method :#{method}, :#{new_name}") rescue nil
      remove_method(new_name)
    end

    def backup_method(method)
      if @klass.respond_to?(method)
        !@klass.respond_to?(new_name = before_stubbing_method_name(method)) &&
          @metaclass.instance_eval("alias_method :#{new_name}, :#{method}")
        true
      else
        false
      end
    end

    def remove_method(method)
      @metaclass.send(:remove_method, method) rescue nil
    end

    def replace_methods(&blk)
      (tmp = BlankObject.new).__instance_eval__(&blk)
      methods_in_block = tmp.__methods__ - BlankObject.new.__methods__
      is_method_implemented_flags = methods_in_block.inject({}) do |memo, method|
        memo.merge(method => backup_method(method))
      end
      @klass.instance_eval(&blk)
      is_method_implemented_flags
    end

    def before_stubbing_method_name(method)
      :"__#{method}_before_xstubbing"
    end

  end

  class BlankObject
    alias_method :__instance_eval__, :instance_eval
    alias_method :__methods__, :methods
    instance_methods.each {|m| undef_method m unless m =~ /^__.*__$/ }
  end

end
