module CrossStub
  module Arguments #:nodoc:
    module Proc

      class << self
        def parse(&block)
          CodeBlock.new(&block).methods_hash
        end
      end

      class CodeBlock

        RUBY_PARSER = RubyParser.new
        RUBY_2_RUBY = Ruby2Ruby.new

        def initialize(&block)
          @block = block
          @methods_hash = ref_methods.inject({}) do |memo, method|
            memo.merge(:"#{method}" => extract_code(method))
          end
        end

        attr_reader :methods_hash

        private

          def extract_code(method)
            ignore, _, code = source_code.match(code_regexp(method))[1..3]
            remaining = source_code.sub(ignore,'')
            while frag = remaining[/^(.*?\Wend)/m,1]
              begin
                sexp = RUBY_PARSER.parse(code += frag)
                return RUBY_2_RUBY.process(sexp) if sexp.inspect =~ sexp_regexp(method)
              rescue SyntaxError, Racc::ParseError, NoMethodError
                remaining.sub!(frag,'')
              end
            end
          end

          def ref_methods
            @ref_methods ||= (
              (object = Minimalist.new).__instance_eval__(&@block)
              object.__methods__ - Minimalist.instance_methods
            )
          end

          def source_code
            @source_code ||= (
              file, line_no = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(@block.inspect)[1..2]
              File.readlines(file)[line_no.to_i.pred .. -1].join
            )
          end

          def code_regexp(method)
            /^(.*?(do|\{)\s*.*?(def\s*#{method}\W))/m
          end

          def sexp_regexp(method)
            /^(s\(:defn,\ :#{method},\ s\(:args.*\),\ s\(:scope,\ s\(:block,\ .*\))$/
          end

          class Minimalist
            alias_method :__instance_eval__, :instance_eval
            alias_method :__methods__, :methods
            orig_verbosity, $VERBOSE = $VERBOSE, nil
            instance_methods.each{|meth| undef_method(meth) if meth.to_s !~ /^__.*?__$/ }
            $VERBOSE = orig_verbosity
          end

      end
    end
  end
end
