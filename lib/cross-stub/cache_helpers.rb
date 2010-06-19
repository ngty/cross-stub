module CrossStub

  private

  module CacheHelpers

    def setup_cache
      File.open(class_cache_file, 'w') {|f| Marshal.dump({}, f) }
      File.open(instance_cache_file, 'w') {|f| Marshal.dump({}, f) }
    end

    def update_class_cache(&blk)
      dump_class_cache(yield(load_class_cache))
    end

    def update_instance_cache(&blk)
      dump_instance_cache(yield(load_instance_cache))
    end

    def delete_class_cache
      if File.exists?(class_cache_file)
        File.exists?(backup_class_cache_file) ?
          File.delete(class_cache_file) : File.rename(class_cache_file, backup_class_cache_file)
      end
    end

    def delete_instance_cache
      if File.exists?(instance_cache_file)
        File.exists?(backup_instance_cache_file) ?
          File.delete(instance_cache_file) : File.rename(instance_cache_file, backup_instance_cache_file)
      end
    end

    def load_class_cache
      File.open(class_cache_file,'r') {|f| Marshal.load(f) }
    end

    def load_instance_cache
      File.open(instance_cache_file,'r') {|f| Marshal.load(f) }
    end

    def load_backup_class_cache
      cache = {}
      if File.exists?(backup_class_cache_file)
        cache = File.open(backup_class_cache_file, 'r') {|f| Marshal.load(f) }
        File.delete(backup_class_cache_file)
      end
      cache
    end

    def load_backup_instance_cache
      cache = {}
      if File.exists?(backup_instance_cache_file)
        cache = File.open(backup_instance_cache_file, 'r') {|f| Marshal.load(f) }
        File.delete(backup_instance_cache_file)
      end
      cache
    end

    def dump_class_cache(data)
      File.open(class_cache_file,'w') {|f| Marshal.dump(data, f) }
    end

    def dump_instance_cache(data)
      File.open(instance_cache_file,'w') {|f| Marshal.dump(data, f) }
    end

    def backup_class_cache_file
      %\#{options[:file]}.class.cache.bak\
    end

    def backup_instance_cache_file
      %\#{options[:file]}.instance.cache.bak\
    end

    def class_cache_file
      %\#{options[:file]}.class.cache\
    end

    def instance_cache_file
      %\#{options[:file]}.instance.cache\
    end

  end
end
