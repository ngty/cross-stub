require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'class_definitions')
require File.join(File.dirname(__FILE__), 'echo_server')

def get_context(klass_or_module)
  klass_or_module.split(/::/).inject(Object) { |context, name| context.const_get(name) }
end

shared 'has standard setup' do
  before do
    CrossStub.setup(cache_store(@store_type))
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
    @get_value = lambda do |klass_and_method_and_args|
      (value = EchoClient.get(klass_and_method_and_args)) !~ /^undefined method/ ? value :
        Object.we_just_wanna_trigger_a_no_method_error_with_this_very_long_and_weird_method!
    end

    # NOTE: Start echo server only if:
    # * it has never been started
    # * the previous store_type is not the same as the current store type
    (c = $cache_stores_in_action ||= []) << @store_type
    if ENV['ECHO_SERVER'] != 'false' && (c.size == 1 or c[-2 .. -1].uniq.size == 2)
      EchoServer.stop rescue nil
      $echo_server_started = true
      EchoServer.start(@store_type)
    end
  end
end

at_exit do
  $echo_server_started && (
    EchoServer.stop unless ENV['ECHO_SERVER'] == 'false'
  )
end
