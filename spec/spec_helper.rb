require 'rubygems'
require 'bacon'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cache-stub'
require 'helpers'

Bacon.summary_on_exit

shared 'has standard setup' do
  before do
    EchoServer.start
    CacheStub.setup(:file => '/tmp/cachemock.cache', :pid => EchoServer.pid)
  end
  after do
    CacheStub.clear
    EchoServer.stop
  end
end

shared 'has current process setup' do
  before do
    @get_value = lambda do |klass_and_method|
      klass, method = klass_and_method.split('.')
      Object.const_get(klass).send(method)
    end
  end
end

shared 'has other process setup' do
  before do
    @get_value = lambda do |klass_and_method|
      (value = EchoClient.get(klass_and_method)) !~ /^undefined method/ ? value :
        Object.we_just_wanna_trigger_a_no_method_error_with_this_very_long_and_weird_method!
    end
  end
end

