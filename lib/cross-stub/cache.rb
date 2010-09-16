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
          type, arg = opts.to_a[0].map{|o| o.to_s }
          @store =
            begin
              store_name = '%s%s' % [type[0..0].upcase, type[1..-1].downcase]
              Stores.const_get(store_name).new(arg, truncate)
            rescue
              raise UnsupportedCacheStore.new('Store type :%s is not supported !!' % type)
            end
        end

    end
  end
end
