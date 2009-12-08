require 'rubygems'
require 'eventmachine'

$cache_file = File.join(File.dirname(__FILE__), '..', 'tmp', 'stubbing.cache')
$log_file = File.join(File.dirname(__FILE__), '..', 'tmp', 'echoserver.log')
$sleep_time = 1.5  # may need to increase this depending on ur machine's prowess

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cross-stub'

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
        sleep $sleep_time
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
        $logger << "(1) EchoServer::EM#receive_data ... receives: #{klass_and_method}\n"
        CrossStub.refresh(:file => $cache_file)
        $logger << "(2) EchoServer::EM#receive_data ... completes stubs refresh\n"
        klass, method, *args = klass_and_method.split('.')
        $logger << "(3) EchoServer::EM#receive_data ... parses arguments to:\n"
        $logger << "    * klass  ... #{klass}\n"
        $logger << "    * method ... #{method}\n"
        $logger << "    * args   ... #{args.inspect}\n"
        value =
          if args.empty?
            Object.const_get(klass).send(method) rescue $!
          else
            Object.const_get(klass).send(method, *args) rescue $!
          end
        $logger << "(4) EchoServer::EM#receive_data ... returns: #{value.inspect}\n"
        send_data(value.nil? ? '<NIL>' : value)
        $logger << "(5) EchoServer::EM#receive_data ... end\n"
      end
    end

end

if $0 == __FILE__
  begin
    require 'logger'
    $logger = Logger.new($log_file)
    EchoServer.start(true)
  ensure
    $logger.close
  end
end
