module CacheStub

  class Error < Exception ; end
  class CannotStubInstanceError < Error ; end

  class << self

    def setup(opts)
      @options = opts
      File.open(options[:file], 'w') {|f| Marshal.dump({}, f) }
    end

    def clear
      if File.exists?(options[:file])
        unapply ; delete
      end
    end

    def apply(klass, args, &blk)
      update do |old_cache|
        new_cache =
          if args[0].is_a?(Hash)
            args[0].inject(old_cache) {|cache, args| create_stub(klass, cache, args[0], args[1]) }
          elsif !args.empty?
            args.inject(old_cache) {|cache, method| create_stub(klass, cache, method, nil) }
          else
            old_cache
          end
        block_given? ? create_stub_from_block(klass, new_cache, &blk) : new_cache
      end
    end

    private

      class BlankObject
        alias_method :__instance_eval, :instance_eval
        alias_method :__methods, :methods
        instance_methods.each do |m|
          undef_method m unless %w{__instance_eval __methods}.include?(m)
        end
      end

      attr_reader :options

      def update(&blk)
        dump(yield(load))
      end

      def delete
        File.delete(options[:file])
      end

      def load
        File.open(options[:file],'r') {|f| Marshal.load(f) }
      end

      def dump(data)
        File.open(options[:file],'w') {|f| Marshal.dump(data, f) }
      end

      def unapply
        load.each do |key, has_method_before_stubbing|
          klass, method = key.split(':').map(&:to_sym)
          mklass = metaclass(const_get(klass))
          if has_method_before_stubbing
            before_stub_method = mklass.instance_method("before_stub_#{method}".to_sym)
            mklass.send(:define_method, method, before_stub_method)
          else
            mklass.send(:remove_method, method)
          end
        end
      end

      def create_stub(klass, cache, method, value)
        cache["#{klass}:#{method}"] = has_created_alias_method?(klass, cache, method)
        metaclass(klass).send(:define_method, method) { value }
        cache
      end

      def create_stub_from_block(klass, cache, &blk)
        (tmp = BlankObject.new).__instance_eval(&blk)
        (tmp.__methods - BlankObject.new.__methods).each do |method|
          cache["#{klass}:#{method}"] = has_created_alias_method?(klass, cache, method)
        end
        klass.instance_eval(&blk)
        cache
      end

      def has_created_alias_method?(klass, cache, method)
        if !cache.has_key?(key = "#{klass}:#{method}")
          (cache[key] = klass.respond_to?(method)) &&
            metaclass(klass).send(:alias_method, "before_stub_#{method}".to_sym, method)
        end
        cache[key]
      end

      def metaclass(klass)
        (class << klass ; self ; end)
      end

  end

  module ClassMethods
    def cache_stub(*args, &blk)
      CacheStub.apply(self, args, &blk)
    end
  end

  module InstanceMethods
    def cache_stub(*args)
      raise CacheStub::CannotStubInstanceError
    end
  end

end

Object.send(:extend, CacheStub::ClassMethods)
Object.send(:include, CacheStub::InstanceMethods)
