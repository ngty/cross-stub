class CrossStubGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.file 'config/initializers/cross-stub.rb', 'config/initializers/cross-stub.rb'
      m.file 'features/support/cross-stub.rb', 'features/support/cross-stub.rb'
      m.gsub_file 'config/environments/cucumber.rb', /\z/, "config.gem 'cross-stub', :lib => false, :version => '>=0.2.4' unless File.directory?(File.join(Rails.root, 'vendor/plugins/cross-stub'))\n"
    end
  end

  protected

    def banner
     "Usage: #{$0} cross_stub"
    end

end
