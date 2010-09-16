require 'rubygems'
require 'base64'
require 'ruby2ruby'
require 'sexp_processor'
require 'sourcify'
require 'forwardable'

require 'cross-stub/cache'
require 'cross-stub/stubber'
require 'cross-stub/arguments'
require 'cross-stub/stores'
require 'cross-stub/fixes'

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
      if args[-1].is_a?(::Hash) && args[-1][:instance]
        raise ModuleCannotBeInstantiatedError if self.class == Module
        CrossStub.apply(
          :instance,                      # stubbing for instance
          self,                           # the class to action on
          '%s#instance' % self,           # cache key (storing of stubbing info for other process)
          args.size>1 ? args[0..-2] : [], # stubbing arguments
          &block                          # any other more complex stubbing arguments
        )
      else
        CrossStub.apply(
          :class,    # stubbing for class/module
          self,      # the class to action on
          "#{self}", # cache key (storing of stubbing info for other process)
          args,      # stubbing arguments
          &block     # any other more complex stubbing arguments
        )
      end
    end
  end

  module InstanceMethods
    def xstub(*args)
      raise CannotStubInstanceError
    end
  end

end

Object.class_eval do
  extend CrossStub::ClassMethods
  include CrossStub::InstanceMethods
end

Module.class_eval do
  include CrossStub::ClassMethods
end
