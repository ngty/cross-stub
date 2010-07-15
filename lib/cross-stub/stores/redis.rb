module CrossStub
  module Stores
    class Redis < Base

      def initialize(connection_and_cache_id, truncate = true)
        require 'redis'
        connection, @cache_id = connection_and_cache_id.split('/')
        host, port = connection.split(':')
        @redis = ::Redis.new(:host => host, :port => port.to_i)
        super(truncate)
      end

      def current
        @cache_id
      end

      def previous
        "#{@cache_id}.stale"
      end

      private

        def exists?(cache_id)
          not @redis[cache_id].nil?
        end

        def dump(cache_id, data)
          @redis[cache_id] = Marshal.dump(data)
        end

        def load(cache_id)
          (data = @redis[cache_id] ) ? Marshal.load(data) : {}
        end

        def delete(cache_id)
          @redis.del(cache_id)
        end

    end
  end
end
