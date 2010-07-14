module CrossStub
  module Stores
    class Memcache < Base

      def initialize(connection_and_cache_id, truncate = true)
        require_libs
        connection, @cache_id = connection_and_cache_id.split('/')
        @memcache = MemCache.new(connection)
        truncate && dump(current, {})
      end

      def current
        @cache_id
      end

      def previous
        "#{@cache_id}.stale"
      end

      private

        def require_libs
          require 'rubygems'
          require 'memcache'
        end

        def exists?(cache_id)
          not @memcache[cache_id].nil?
        end

        def dump(cache_id, data)
          @memcache[cache_id] = data
        end

        def load(cache_id)
          @memcache[cache_id] || {}
        end

        def delete(cache_id)
          @memcache.delete(cache_id)
        end

    end
  end
end
