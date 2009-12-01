module CacheStub

  private

  module CacheHelpers

    def update_cache(&blk)
      dump_cache(yield(load_cache))
    end

    def delete_cache
      File.delete(options[:file])
    end

    def load_cache
      File.open(options[:file],'r') {|f| Marshal.load(f) }
    end

    def dump_cache(data)
      File.open(options[:file],'w') {|f| Marshal.dump(data, f) }
    end

  end
end
