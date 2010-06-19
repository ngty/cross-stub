module CrossStub

  private

  module SetupHelpers

    def setup_for_current_process
      setup_cache
    end

  end

  module DEBUG
    $debug_file = File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'debug.log')

    def self.print(msg)
      File.open($debug_file, "a") do |f|
        f.puts msg
      end
    end

  end


end
