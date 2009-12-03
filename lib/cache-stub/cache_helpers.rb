module CacheStub

  private

  module CacheHelpers

    def setup_cache
      File.open(cache_file, 'w') {|f| Marshal.dump({}, f) }
    end

    def update_cache(&blk)
      dump_cache(yield(load_cache))
    end

    def delete_cache
      File.rename(cache_file, backup_cache_file) if File.exists?(cache_file)
    end

    def load_cache
      File.open(cache_file,'r') {|f| Marshal.load(f) }
    end

    def load_backup_cache
      cache = File.open(backup_cache_file, 'r') {|f| Marshal.load(f) } rescue {}
      File.delete(backup_cache_file)
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
