module CrossStub

  class UnsupportedCacheStore < Exception ; end

  module Cache
    class << self

      extend Forwardable
      def_delegator :@store, :clear
      def_delegator :@store, :get
      def_delegator :@store, :set

      def setup(opts)
        init(opts, true)
      end

      def refresh(opts)
        init(opts, false)
      end

      private

        def init(opts, truncate)
          type, arg = opts.to_a[0]
          @store =
            case type
            when :file then Stores::File.new(arg, truncate)
            else raise UnsupportedCacheStore.new('Store type :%s is not supported !!' % type)
            end
        end

    end
  end
end
