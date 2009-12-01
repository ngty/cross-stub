module CacheStub

  private

  module SetupHelpers

    def setup_for_current_process
      # opts[:pid] = File.open(opts[:pid],'r') {|f| f.gets } if opts[:pid].to_s !~ /^\d+$/
      File.open(options[:file], 'w') {|f| Marshal.dump({}, f) }
    end

    def setup_for_other_process
      raise NotImplementedError
    end

  end
end
