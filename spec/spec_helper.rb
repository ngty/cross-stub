require 'rubygems'
require 'bacon'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'helpers'

Bacon.summary_on_exit

shared 'has standard setup' do
  before do
    CrossStub.setup(:file => $cache_file)
  end
  after do
    CrossStub.clear
  end
end

shared 'has current process setup' do
  before do
    @get_value = lambda do |klass_and_method_and_args|
      klass, method, *args = klass_and_method_and_args.split('.')
      args.empty? ? Object.const_get(klass).send(method) :
        Object.const_get(klass).send(method, *args)
    end
  end
end

shared 'has other process setup' do
  before do
    EchoServer.start
    @get_value = lambda do |klass_and_method_and_args|
      (value = EchoClient.get(klass_and_method_and_args)) !~ /^undefined method/ ? value :
        Object.we_just_wanna_trigger_a_no_method_error_with_this_very_long_and_weird_method!
    end
  end
  after do
    EchoServer.stop
  end
end

