require 'rubygems'
require 'parse_tree'
require 'ruby2ruby'
require 'cross-stub/stub_helpers'
require 'cross-stub/setup_helpers'
require 'cross-stub/cache_helpers'
require 'cross-stub/pseudo_class'

module CrossStub

  class Error < Exception ; end
  class CannotStubInstanceError < Error ; end

  class << self

    include CacheHelpers
    include SetupHelpers
    include StubHelpers

    attr_reader :options

    def setup(opts)
      @options = opts
      setup_for_current_process
    end

    def clear
      clear_stubs_for_current_process
    end

    def apply(*args, &blk)
      apply_stubs_for_current_process(*args, &blk)
    end

    def refresh(opts)
      @options = opts
      apply_or_unapply_stubs_for_other_process
    end

  end

  module ClassMethods
    def xstub(*args, &blk)
      CrossStub.apply(self, args, &blk)
    end
  end

  module InstanceMethods
    def xstub(*args)
      raise CannotStubInstanceError
    end
  end

end

Object.send(:extend, CrossStub::ClassMethods)
Object.send(:include, CrossStub::InstanceMethods)
