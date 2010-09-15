module CrossStub
  module Arguments #:nodoc:
    module Proc
      class << self

        RUBY_2_RUBY = Ruby2Ruby.new

        def parse(&block)
          methods = {}
          block.to_sexp.each_of_type(:defn) do |_sexp|
            methods[_sexp.to_a[1]] = RUBY_2_RUBY.process(_sexp)
          end
          methods
        end

      end
    end
  end
end
