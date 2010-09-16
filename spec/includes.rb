unless Object.const_defined?(:RUBY_VM)

# ///////////////////////////////////////////////////////////////////////
# Constants
# ///////////////////////////////////////////////////////////////////////

RUBY_VM = [
  RUBY_VERSION.gsub(/[^\d]/,''),
  RUBY_PLATFORM =~ /java/i ? 'j' : '',
  (Object.const_defined?(:RUBY_DESCRIPTION) ? RUBY_DESCRIPTION : '') =~ /enterprise/i ? 'e' : ''
].join

PROJECT_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '..')
PROJECT_FILE = lambda{|*args| File.join(*[PROJECT_ROOT, *args]) }

CACHE_STORES = {
  :file => PROJECT_FILE['tmp', "stubbing-#{RUBY_VM}.cache"],
  :memcache => "localhost:11211/stubbing-#{RUBY_VM}.cache",
  :redis => "localhost:6379/stubbing-#{RUBY_VM}.cache",
}

# /////////////////////////////////////////////////////////////////////////////////////////
# Configuring otaku service
# /////////////////////////////////////////////////////////////////////////////////////////

require 'otaku' unless Object.const_defined?('Otaku')
Otaku.configure do |config|
  config.log_file = PROJECT_FILE['tmp', "otaku-#{RUBY_VM}.log"]
end

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
  (value = Otaku.process(store_type_and_klass_and_method_and_args)) !~ /^undefined method/ ?
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
