module CrossStub
  module Stubber #:nodoc:

    class << self

      EXIST, CODE = 0, 1

      extend Forwardable
      def_delegator :@thing, :m_eval
      def_delegator :@thing, :t_eval
      def_delegator :@thing, :has_method?

      def apply(type, thing, stubs)
        initialize_vars(type, thing, stubs)
        @stubs.values[0].is_a?(::Hash) ?
          apply_stubbing_only : apply_stubbing_and_return_cacheables
      end

      def unapply(type, thing, stubs)
        initialize_vars(type, thing, stubs)
        @stubs.each do |method, args|
          args[EXIST] ? unapply_aliasing(method) : remove_method(method)
          unstubbify(method)
        end
      end

      private

        def initialize_vars(type, thing, stubs)
          @thing, @stubs = (type == :class ? Klass : Instance).new(thing), stubs
        end

        def apply_stubbing_and_return_cacheables
          @stubs.inject({}) do |memo, (method, code)|
            args = {EXIST => really_has_method?(method), CODE => code}
            apply_aliasing(method) if args[EXIST]
            t_eval(code)
            stubbify(method)
            memo.merge(method => args)
          end
        end

        def really_has_method?(method)
          (!stubbified?(method) && has_method?(method)) || has_method?(backup_method(method))
        end

        def apply_stubbing_only
          @stubs.each do |method, args|
            apply_aliasing(method) if args[EXIST]
            t_eval(args[CODE])
          end
        end

        def apply_aliasing(method)
          unless has_method?(backup_meth = backup_method(method))
            m_eval("alias_method :#{backup_meth}, :#{method}")
          end
        end

        def unapply_aliasing(method)
          if has_method?(backup_meth = backup_method(method))
            m_eval("alias_method :#{method}, :#{backup_meth}")
            remove_method(backup_meth)
          end
        end

        def remove_method(method)
          m_eval("undef_method :#{method}") rescue nil
        end

        def stubbified?(method)
          has_method?(flag_method(method))
        end

        def stubbify(method)
          t_eval("def #{flag_method(method)} ; end") rescue nil
        end

        def unstubbify(method)
          remove_method(flag_method(method))
        end

        def backup_method(method)
          "__#{method}_before_xstubbing"
        end

        def flag_method(method)
          "__#{method}_has_been_xstubbed"
        end

    end

    class Instance

      def initialize(thing)
        @thing = thing
      end

      def m_eval(str)
        @thing.class_eval(str)
      end

      alias_method :t_eval, :m_eval

      def has_method?(method)
        @thing.instance_methods.map(&:to_s).include?(method.to_s)
      end

    end

    class Klass

      def initialize(thing)
        @thing = thing
      end

      def m_eval(str)
        (class << @thing ; self ; end).instance_eval(str)
      end

      def t_eval(str)
        @thing.instance_eval(str)
      end

      def has_method?(method)
        @thing.respond_to?(method)
      end

    end

  end
end
