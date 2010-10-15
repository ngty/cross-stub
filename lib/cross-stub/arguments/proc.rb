module CrossStub
  module Arguments #:nodoc:
    module Proc
      class << self

        RUBY_2_RUBY = Ruby2Ruby.new

        def parse(&block)
          methods = {}
          proc_to_sexp(block).each_of_type(:defn) do |_sexp|
            methods[_sexp.to_a[1]] = RUBY_2_RUBY.process(_sexp)
          end
          methods
        end

        def proc_to_sexp(block)
          block.to_sexp(:stip_enclosure => true, :attached_to => :xstub) do |body|
            body =~ /^(.*\W|)def\W/
          end
        end

      end
    end
  end
end
