require 'rubygems'
require 'bacon'
require 'mocha'

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
      konstants = klass.split(/::/)
      if konstants.last.eql?('new')
        konstants.slice!(-1)
        konst = konstants.inject(Object) { |const_train, const| const_train.const_get(const) }
        args.empty? ? konst::new.send(method) :
          konst::new.send(method, *args)
      else
        konst = konstants.inject(Object) { |const_train, const| const_train.const_get(const) }
        args.empty? ? konst.send(method) :
          konst.send(method, *args)
      end
    end
  end
end

shared 'has other process setup' do
  before do
    EchoServer.start unless ENV['ECHO_SERVER'] == 'false'
    @get_value = lambda do |klass_and_method_and_args|
      (value = EchoClient.get(klass_and_method_and_args)) !~ /^undefined method/ ? value :
        Object.we_just_wanna_trigger_a_no_method_error_with_this_very_long_and_weird_method!
    end
  end
  after do
    EchoServer.stop unless ENV['ECHO_SERVER'] == 'false'
  end
end

