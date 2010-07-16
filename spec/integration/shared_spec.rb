require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'includes')
require File.join(File.dirname(__FILE__), '..', 'service')

shared 'has standard setup' do
  before { CrossStub.setup(cache_store(@store_type)) }
  after { CrossStub.clear }
end

shared 'has current process setup' do
  behaves_like 'has standard setup'
  before { @get_value = Object.method(:do_local_method_call) }
end

shared 'has other process setup' do

  behaves_like 'has standard setup'

  before do
    @get_value = lambda do |klass_and_method_and_args|
      do_remote_method_call("%s/%s" % [@store_type, klass_and_method_and_args])
    end
    $service_started ||= (
      EchoServer.start if ENV['ECHO_SERVER'] != 'false'
      true
    )
  end

end

at_exit do
  $service_started && (
    EchoServer.stop unless ENV['ECHO_SERVER'] == 'false'
  )
end
