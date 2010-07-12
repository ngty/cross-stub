module CrossStub
  module Arguments #:nodoc:
    module Proc

      class Minimalist
        alias_method :__instance_eval__, :instance_eval
        alias_method :__methods__, :methods
        instance_methods.each{|meth| undef_method(meth) if meth.to_s !~ /^__.*?__$/ }
      end

      class CodeBlock

        RUBY_2_RUBY = Ruby2Ruby.new
        attr_reader :methods_hash

        def initialize(block)
          sexp = extract_sexp(block)
          (object = Minimalist.new).__instance_eval__(&block)
          newly_added_methods = object.__methods__ - Minimalist.instance_methods
          @methods_hash = newly_added_methods.inject({}) do |memo, method|
            memo.merge(:"#{method}" => extract_code(method, sexp))
          end
        end

        private

          def extract_code(method, sexp, code = nil)
            sexp.each do |_sexp|
              break if (
                code =
                  case _sexp.inspect
                  when /^s\(:defn, :#{method}/ then RUBY_2_RUBY.process(_sexp)
                  when /^s\(:block, / then extract_code(method, _sexp)
                  end
              )
            end
            code
          end

          def extract_sexp(block)
            (ParseTree && block.to_sexp) rescue nil
          end

      end

      class << self
        def parse(block)
          CodeBlock.new(block).methods_hash
        end
      end

    end
  end
end

