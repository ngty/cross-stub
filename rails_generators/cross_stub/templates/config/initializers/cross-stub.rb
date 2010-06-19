if ENV['RAILS_ENV'] == 'cucumber'
  class ActionController::Dispatcher
    def refresh_stubs
      CrossStub.refresh :file => File.join(RAILS_ROOT, 'tmp', 'cross-stub')
    end
    before_dispatch :refresh_stubs
  end
end
