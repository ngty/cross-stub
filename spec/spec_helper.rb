require 'rubygems'
require 'bacon'
require File.join(File.dirname(__FILE__), 'includes')

Bacon.extend(Bacon::TestUnitOutput)
Bacon.summary_on_exit

if ENV['MUTE_BACON'] == 'true'
  Bacon.extend(Module.new {

    def handle_requirement(description)
      unless (error = yield).empty?
        print error[0..0]
      end
    end

    def handle_summary
      puts "", "  %d tests, %d assertions, %d failures, %d errors" %
        Bacon::Counter.values_at(:specifications, :requirements, :failed, :errors)
    end

  })
end
