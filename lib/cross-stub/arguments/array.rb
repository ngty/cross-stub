module CrossStub
  module Arguments #:nodoc:
    module Array
      class << self

        def parse(symbols)
          symbols.inject({}) do |memo, name|
            code = "def #{name} ; nil ; end"
            memo.merge(:"#{name}" => code)
          end
        end

      end
    end
  end
end
