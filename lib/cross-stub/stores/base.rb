module CrossStub

  class UnsupportedStoreGetMode < Exception ; end

  module Stores
    class Base

      def get(mode = :current)
        case mode
        when :current then load(current)
        when :previous
          data = load(previous)
          delete(previous)
          data
        else raise UnsupportedStoreGetMode
        end
      end

      def set(data, mode = :current)
        case mode
        when :current then dump(current, data)
        when :previous then dump(previous, data)
        else raise UnsupportedStoreGetMode
        end
      end

      def clear
        set(get(:current), :previous) unless exists?(previous)
        delete(current)
      end

    end
  end
end
