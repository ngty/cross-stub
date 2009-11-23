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

    def apply(klass, args)
      update do |old_cache|
        if !args.first.is_a?(Hash)
          args.inject(old_cache) {|cache, method| create_stub(klass, cache, method, nil) }
        else
          args[0].inject(old_cache) {|cache, args| create_stub(klass, cache, args[0], args[1]) }
        end
      end
    end

    private

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
        mklass = metaclass(klass)
        if !cache.has_key?("#{klass}:#{method}")
          already_has_method = klass.respond_to?(method)
          cache["#{klass}:#{method}"] = already_has_method
          mklass.send(:alias_method, "before_stub_#{method}".to_sym, method) if already_has_method
        end
        mklass.send(:define_method, method) { value }
        cache
      end

      def metaclass(klass)
        (class << klass ; self ; end)
      end

  end

  module ClassMethods
    def cache_stub(*args)
      CacheStub.apply(self, args)
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
