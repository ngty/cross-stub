module CrossStub
  module Stores
    class File

      include Traits

      def initialize(file, truncate = true)
        @file = file
        truncate && dump(current, {})
      end

      def current
        @file
      end

      def previous
        "#{@file}.stale"
      end

      private


        def exists?(file)
          ::File.exists?(file)
        end

        def dump(file, data)
          ::File.open(file,'w') {|f| Marshal.dump(data, f) } rescue nil
        end

        def load(file)
          ::File.open(file,'r') {|f| Marshal.load(f) } rescue {}
        end

        def delete(file)
          ::File.delete(file) if exists?(file)
        end

    end
  end
end
