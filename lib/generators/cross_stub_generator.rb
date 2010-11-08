class CrossStubGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def install_cross_stub
    copy_file 'config/initializers/cross-stub.rb', 'config/initializers/cross-stub.rb'
    copy_file 'features/support/cross-stub.rb', 'features/support/cross-stub.rb'
    gsub_file 'config/environments/cucumber.rb', /\z/, "config.gem 'cross-stub', :version => '>=0.2.0'\n"
  end
end
