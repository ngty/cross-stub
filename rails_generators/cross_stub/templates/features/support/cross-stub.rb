require 'cross-stub'
Before { CrossStub.setup :file => File.join(RAILS_ROOT, 'tmp', 'cross-stub.cache') }
After  { CrossStub.clear }
