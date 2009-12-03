require 'rubygems'
require 'eventmachine'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cache-stub'

class AnyClass
  def self.say_world
    'u say world'
  end
end

class AnyModule
  def self.say_world
    'u say world'
  end
end

module EchoClient

  class << self

    attr_accessor :result

    def get(klass_and_method)
      address, port = EchoServer::ADDRESS, EchoServer::PORT
      EventMachine::run do
        (EventMachine::connect(address, port, EM)).
          execute(klass_and_method) {|data| self.result = data }
      end
      (self.result == '<NIL>') ? nil : self.result
    end

  end

  private

    module EM
      def receive_data(data)
        @callback[data]
        EventMachine::stop_event_loop
      end
      def execute(method, &blk)
        @callback = blk
        send_data method
      end
    end

end

module EchoServer

  ADDRESS, PORT = '127.0.0.1', 8081

  class << self

    def pid
      @process.pid
    end

    def start(other_process=false)
      unless other_process
        @process = IO.popen("ruby #{__FILE__}")
        sleep 1
      else
        EventMachine::run { EventMachine::start_server(ADDRESS, PORT, EM) }
      end
    end

    def stop
      Process.kill('SIGHUP', pid)
    end

  end

  private

    module EM
      def receive_data(klass_and_method)
        CacheStub.refresh(:file => '/tmp/cachemock.cache')
        klass, method = klass_and_method.split('.')
        value = Object.const_get(klass).send(method) rescue $!
        send_data(value.nil? ? '<NIL>' : value)
      end
    end

end

EchoServer.start(true) if ($0 == __FILE__)
