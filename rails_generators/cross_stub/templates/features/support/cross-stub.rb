require 'cross-stub'
Before { CrossStub.setup :file => File.join(RAILS_ROOT, 'tmp', 'cross-stub') }
After  { CrossStub.clear }
