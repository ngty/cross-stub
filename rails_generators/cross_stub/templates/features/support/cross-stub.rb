require 'cross-stub'

Before do
  CrossStub.setup :file => File.join(RAILS_ROOT, 'tmp', 'stubbing.cache')
end
