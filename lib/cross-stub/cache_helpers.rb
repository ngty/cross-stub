module CrossStub

  private

  module CacheHelpers

    def setup_cache
      File.open(cache_file, 'w') {|f| Marshal.dump({}, f) }
    end

    def update_cache(&blk)
      dump_cache(yield(load_cache))
    end

    def delete_cache
      if File.exists?(cache_file)
        File.exists?(backup_cache_file) ?
          File.delete(cache_file) : File.rename(cache_file, backup_cache_file)
      end
    end

    def load_cache
      File.open(cache_file,'r') {|f| Marshal.load(f) }
    end

    def load_backup_cache
      cache = {}
      if File.exists?(backup_cache_file)
        cache = File.open(backup_cache_file, 'r') {|f| Marshal.load(f) }
        File.delete(backup_cache_file)
      end
      cache
    end

    def dump_cache(data)
      File.open(cache_file,'w') {|f| Marshal.dump(data, f) }
    end

    def backup_cache_file
      %\#{options[:file]}.bak\
    end

    def cache_file
      options[:file]
    end

  end
end
