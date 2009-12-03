module CacheStub

  private

  module StubHelpers

    def clear_stubs_for_current_process
      if File.exists?(options[:file])
        unapply_stubs ; delete_cache
      end
    end

    def apply_stubs_for_current_process(*args, &blk)
      pk, args = PseudoClass.new(args[0]), args[1]
      update_cache do |entire_cache|
        hash = (args[0].is_a?(Hash) ? args[0] : args.inject({}){|h, k| h.merge(k => nil) })
        cache = entire_cache[pk.id] || {}
        cache = create_stub_from_hash(pk, cache, hash)
        cache = create_stub_from_block(pk, cache, &blk) if block_given?
        entire_cache.merge(pk.id => cache)
      end
    end

    def apply_or_unapply_stubs_for_other_process
      begin
        load_cache.each do |klass, hash|
          pk = PseudoClass.new(klass)
          hash.each {|method, codes| pk.replace_method(method, codes[:after]) }
        end
      rescue
        unapply_stubs(load_backup_cache)
      end
    end

    def unapply_stubs(cache=nil)
      cache ||= load_cache
      cache.each do |klass, hash|
        pk = PseudoClass.new(klass)
        hash.each do |method, codes|
          codes[:before] ? pk.replace_method(method, codes[:before]) : pk.remove_method(method)
        end
      end
    end

    def create_stub_from_hash(pk, cache, hash)
      hash.inject(cache) do |cache, args|
        method, value = args
        original_method_code = pk.replace_method(method, value)
        cache[method] ||= {:before => original_method_code}
        cache[method][:after] = pk.method_code(method)
        cache
      end
    end

    def create_stub_from_block(pk, cache, &blk)
      pk.replace_methods(&blk).inject(cache) do |cache, args|
        method, original_method_code = args
        cache[method] ||= {:before => original_method_code}
        cache[method][:after] = pk.method_code(method)
        cache
      end
    end

  end
end
