require 'rubygems'
require 'ruby2ruby'
require 'forwardable'
require 'cross-stub/cache'
require 'cross-stub/stubber'
require 'cross-stub/arguments'
require 'cross-stub/stores'

begin
  # OPTIONAL, we would use them if they are available (eg. in MRI 1.8).
  require 'parse_tree'
  require 'parse_tree_extensions'
rescue
  # Otherwise, we use ruby_parser .. (OUTSTANDING)
end

module CrossStub

  class Error < Exception ; end
  class CannotStubInstanceError < Error ; end
  class ModuleCannotBeInstantiatedError < Error ; end

  class << self

    extend Forwardable
    def_delegator :'CrossStub::Cache', :setup

    def refresh(opts)
      Cache.refresh(opts)
      [[:previous, :unapply], [:current, :apply]].each do |(mode, method)|
        Cache.get(mode).map do |cache_key, stubs|
          type, thing = stubbable(cache_key)
          Stubber.send(method, type, thing, stubs)
        end
      end
    end

    def clear
      Cache.get.map do |cache_key, stubs|
        type, thing = stubbable(cache_key)
        Stubber.unapply(type, thing, stubs)
      end
      Cache.clear
    end

    def apply(type, thing, cache_key, args, &block)
      Cache.set(Cache.get.merge(
        cache_key => Stubber.apply(type, thing, Arguments.parse(args, &block))
      ))
    end

    def stubbable(str)
      [
        str.end_with?(suffix = '#instance') ? :instance : :class,
        klassify(str.sub(suffix,''))
      ]
    end

    def klassify(str)
      str.split('::').inject(Object){|klass, const| klass.const_get(const) }
    end

  end

  module ClassMethods

    def xstub(*args, &block)
      CrossStub.apply(:class, self, self.to_s, args, &block)
    end

    def xstub_instance(*args, &block)
      CrossStub.apply(:instance, self, '%s#instance' % self, args, &block)
    end

    alias_method :xstub_instances, :xstub_instance

  end

  module ModuleMethods

    include ClassMethods

    def xstub_instance(*args, &block)
      raise ModuleCannotBeInstantiatedError
    end

    alias_method :xstub_instances, :xstub_instance

  end

  module InstanceMethods

    def xstub(*args)
      raise CannotStubInstanceError
    end

    alias_method :xstub_instance, :xstub
    alias_method :xstub_instances, :xstub

  end

end

Object.class_eval do
  extend CrossStub::ClassMethods
  include CrossStub::InstanceMethods
end

Module.class_eval do
  include CrossStub::ModuleMethods
end
