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
      klass_descrp, method, *args = klass_and_method_and_args.split('.')
      is_instance = klass_descrp.end_with?(suffix = '#new')
      klass = klass_descrp.sub(suffix,'').split(/::/).inject(Object){|k,c| k.const_get(c) }
      receiver = is_instance ? klass.new : klass
      args.empty? ? receiver.send(method) : receiver.send(method, *args)
    end
  end
end

shared 'has other process setup' do
  before do
    @get_value = lambda do |klass_and_method_and_args|
      args = "%s/%s" % [@store_type, klass_and_method_and_args]
      (value = EchoClient.get(args)) !~ /^undefined method/ ? value :
        Object.we_just_wanna_trigger_a_no_method_error_with_this_very_long_and_weird_method!
    end
    $echo_server_started ||= (
      EchoServer.start if ENV['ECHO_SERVER'] != 'false'
      true
    )
  end
end

at_exit do
  $echo_server_started && (
    EchoServer.stop unless ENV['ECHO_SERVER'] == 'false'
  )
end
