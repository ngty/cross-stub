require 'rubygems'
require 'parse_tree'
require 'ruby2ruby'
require 'cache-stub/stub_helpers'
require 'cache-stub/setup_helpers'
require 'cache-stub/cache_helpers'
require 'cache-stub/pseudo_class'

module CacheStub

  class Error < Exception ; end
  class NotImplementedError < Error ; end
  class CannotStubInstanceError < Error ; end

  class << self

    include CacheHelpers
    include SetupHelpers
    include StubHelpers

    attr_reader :options

    def setup(opts)
      @options = opts
      current_process? ? setup_for_current_process : setup_for_other_process
    end

    def clear
      current_process? ? clear_stubs_for_current_process : clear_stubs_for_other_process
    end

    def apply(*args, &blk)
      current_process? ? apply_stubs_for_current_process(*args, &blk) : apply_stubs_for_other_process
    end

    def current_process?
      !options[:pid].nil?
    end

  end

  module ClassMethods
    def cache_stub(*args, &blk)
      CacheStub.apply(self, args, &blk)
    end
  end

  module InstanceMethods
    def cache_stub(*args)
      raise CacheStub::CannotStubInstanceError
    end
  end

end

Object.send(:extend, CacheStub::ClassMethods)
Object.send(:include, CacheStub::InstanceMethods)
