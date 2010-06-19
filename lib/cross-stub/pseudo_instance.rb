module CrossStub

  private

  class PseudoInstance

    @@translator ||= lambda do |klass, method|
      @@convertor ||= lambda {|sexp| Ruby2Ruby.new.process(Unifier.new.process(sexp)) }
      @@convertor[ParseTree.translate(klass, method)] rescue nil
    end

    def initialize(klass)
      @klass = get_class(klass)
      @metaclass = (class << @klass ; self ; end)
      @instance = @klass.new
    end

    def get_class(klass)
      if klass.is_a?(String)
        klass.split(/::/).inject(Object) { |const_train, const| const_train.const_get(const) }
      else
        klass
      end
    end

    def id
      @klass.to_s
    end

    def method_code(method)
      @@translator[@klass, method]
    end

    def replace_method(method, value_or_code)
      status = backup_method(method)
      @klass.class_eval "#{value_or_code}" =~ /^def / ? value_or_code :
          %\def #{method}; Marshal.load(%|#{Marshal.dump(value_or_code)}|) ; end\
      status
    end

    def revert_method(method)
      new_name = before_stubbing_method_name(method)
      @klass.class_eval("alias_method :#{method}, :#{new_name}") rescue nil
      remove_method(new_name)
    end

    def backup_method(method)
      if @instance.respond_to?(method)
        !@instance.respond_to?(new_name = before_stubbing_method_name(method)) &&
          @klass.class_eval("alias_method :#{new_name}, :#{method}")
        true
      else
        false
      end
    end

    def remove_method(method)
      @klass.send(:remove_method, method) rescue nil
    end

    def replace_methods(&blk)
      (tmp = BlankObject.new).__instance_eval__(&blk)
      methods_in_block = tmp.__methods__ - BlankObject.new.__methods__
      is_method_implemented_flags = methods_in_block.inject({}) do |memo, method|
        memo.merge(method => backup_method(method))
      end
      @klass.class_eval(&blk)
      is_method_implemented_flags
    end

    def before_stubbing_method_name(method)
      :"__#{method}_before_xstubbing"
    end

  end

end
