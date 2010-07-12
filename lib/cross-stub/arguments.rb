require 'cross-stub/arguments/hash'
require 'cross-stub/arguments/array'
require 'cross-stub/arguments/proc'

module CrossStub
  module Arguments #:nodoc:
    class << self

      def parse(args, &block)
        (
          case args[0]
          when ::Hash then Hash.parse(args[0])
          when ::Symbol then Array.parse(args)
          else {}
          end
        ).merge(block_given? ? Proc.parse(block) : {})
      end

    end
  end
end
