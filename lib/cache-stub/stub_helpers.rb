module CacheStub

  private

  module StubHelpers

    def clear_stubs_for_current_process
      if File.exists?(options[:file])
        unapply_stubs ; delete_cache
      end
    end

    def clear_stubs_for_other_process
      raise NotImplementedError
    end

    def apply_stubs_for_current_process(*args, &blk)
      pklass, args = PseudoClass.new(args[0]), args[1]
      update_cache do |entire_cache|
        hash = (args[0].is_a?(Hash) ? args[0] : args.inject({}){|h, k| h.merge(k => nil) })
        cache = entire_cache[pklass.id] || {}
        cache = create_stub_from_hash(pklass, cache, hash)
        cache = create_stub_from_block(pklass, cache, &blk) if block_given?
        entire_cache.merge(pklass.id => cache)
      end
    end

    def apply_stubs_for_other_process
      raise NotImplementedError
    end

    def unapply_stubs
      load_cache.each do |klass, hash|
        pklass = PseudoClass.new(klass)
        hash.each do |method, codes|
          codes[:before] ?
            pklass.replace_method(method, codes[:before]) :
            pklass.remove_method(method)
        end
      end
    end

    def create_stub_from_hash(pklass, cache, hash)
      hash.inject(cache) do |cache, args|
        method, value = args
        original_method_code = pklass.replace_method(method, value)
        cache[method] ||= {:before => original_method_code}
        cache[method][:after] = pklass.method_code(method)
        cache
      end
    end

    def create_stub_from_block(pklass, cache, &blk)
      pklass.replace_methods(&blk).inject(cache) do |cache, args|
        method, original_method_code = args
        cache[method] ||= {:before => original_method_code}
        cache[method][:after] = pklass.method_code(method)
        cache
      end
    end

  end
end
