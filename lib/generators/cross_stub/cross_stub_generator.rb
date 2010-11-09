class CrossStubGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def generate
    copy_file 'config/initializers/cross-stub.rb', 'config/initializers/cross-stub.rb'
    copy_file 'features/support/cross-stub.rb', 'features/support/cross-stub.rb'
  end
end
