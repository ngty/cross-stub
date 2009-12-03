require 'rubygems'
require 'bacon'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helpers'

Bacon.summary_on_exit

shared 'has standard setup' do
  before do
    CacheStub.setup(:file => '/tmp/cachemock.cache')
  end
  after do
    CacheStub.clear
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
    EchoServer.start
    @get_value = lambda do |klass_and_method|
      (value = EchoClient.get(klass_and_method)) !~ /^undefined method/ ? value :
        Object.we_just_wanna_trigger_a_no_method_error_with_this_very_long_and_weird_method!
    end
  end
  after do
    EchoServer.stop
  end
end

