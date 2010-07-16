unless Object.const_defined?(:RUBY_VM)

# ///////////////////////////////////////////////////////////////////////
# Constants
# ///////////////////////////////////////////////////////////////////////

RUBY_VM = [
  RUBY_VERSION.gsub(/[^\d]/,''),
  RUBY_PLATFORM =~ /java/i ? 'j' : '',
  RUBY_DESCRIPTION =~ /enterprise/i ? 'e' : ''
].join

PROJECT_ROOT = File.join(File.dirname(__FILE__), '..')
PROJECT_FILE = lambda{|*args| File.join(*[PROJECT_ROOT, *args]) }

CACHE_STORES = {
  :file => PROJECT_FILE['tmp', "stubbing-#{RUBY_VM}.cache"],
  :memcache => "localhost:11211/stubbing-#{RUBY_VM}.cache",
  :redis => "localhost:6379/stubbing-#{RUBY_VM}.cache",
}

ECHO_SERVER_INIT_WAIT_TIME = RUBY_VM.end_with?('j') ? 10 : 2
ECHO_SERVER_LOG = PROJECT_FILE['tmp', "echoserver-#{RUBY_VM}.log"]
ECHO_SERVER_HOST = '127.0.0.1'
ECHO_SERVER_PORT = 10000 + RUBY_VM[/(\d+)/,1].to_i + ({'j' => 7, 'e' => 17}[RUBY_VM[-1..-1]] || 0)

# /////////////////////////////////////////////////////////////////////////////////////////
# Useful methods
# /////////////////////////////////////////////////////////////////////////////////////////

def cache_store(id)
  {(id = :"#{id}") => CACHE_STORES[id]}
end

def each_cache_store(&block)
  CACHE_STORES.keys.each do |store_type|
    yield(store_type)
  end
end

def do_local_method_call(klass_and_method_and_args)
  klass, is_instance, method, args = parse_call_args(klass_and_method_and_args)
  receiver = is_instance ? klass.new : klass
  args.empty? ? receiver.send(method) : receiver.send(method, *args)
end

def parse_call_args(klass_and_method_and_args)
  klass_descriptor, method, *args = klass_and_method_and_args.split('.')
  is_instance = klass_descriptor.end_with?(suffix = '#new')
  [klassify(klass_descriptor), is_instance, method, args]
end

def do_remote_method_call(store_type_and_klass_and_method_and_args)
  (value = EchoClient.get(store_type_and_klass_and_method_and_args)) !~ /^undefined method/ ?
    value : Object.we_just_wanna_trigger_no_method_error_with_this_weird_method!
end

def klassify(descriptor)
  descriptor.sub('#new','').split(/::/).inject(Object){|k,c| k.const_get(c) }
end

# /////////////////////////////////////////////////////////////////////////////////////////
# Loading of files
# /////////////////////////////////////////////////////////////////////////////////////////

$LOAD_PATH.unshift(PROJECT_FILE['lib'])
require 'cross-stub'

# /////////////////////////////////////////////////////////////////////////////////////////
# Class definitions for specs
# /////////////////////////////////////////////////////////////////////////////////////////

class AnyClass

  def self.say ; 'hello' ; end

  class Inner
    def self.say ; 'hello' ; end
  end

end

class AnyInstance

  def say ; 'hello' ; end

  class Inner
    def say ; 'hello' ; end
  end

end

module AnyModule

  def self.say ; 'hello' ; end

  module Inner
    def self.say ; 'hello' ; end
  end

end

end
