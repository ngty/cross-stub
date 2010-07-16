class CrossStubGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.file 'config/initializers/cross-stub.rb', 'config/initializers/cross-stub.rb'
      m.file 'features/support/cross-stub.rb', 'features/support/cross-stub.rb'
      m.gsub_file 'config/environments/cucumber.rb', /\z/, "config.gem 'cross-stub', :version => '>=0.2.0'\n"
    end
  end

protected

  def banner
    "Usage: #{$0} cross_stub"
  end

end
