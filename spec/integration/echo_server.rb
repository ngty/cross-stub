require 'rubygems'
require 'eventmachine'
require File.join(File.dirname(__FILE__), 'klasses')

$project_root = File.join(File.dirname(__FILE__), '..', '..')
$cache_file = File.join($project_root, 'tmp', 'stubbing')
$log_file = File.join($project_root, 'tmp', 'echoserver.log')
$sleep_time = 2  # may need to increase this depending on ur machine's prowess

$LOAD_PATH.unshift(File.join($project_root, 'lib'))
require 'cross-stub'

module EchoClient

  class << self

    attr_accessor :result

    def get(klass_and_method)
      address, port = EchoServer::ADDRESS, EchoServer::PORT
      EventMachine::run do
        (EventMachine::connect(address, port, EM)).
          execute(klass_and_method) {|data| self.result = Marshal.load(data) }
      end
      self.result
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
        log "\n"
        log "(1) EchoServer::EM#receive_data ... receives: #{klass_and_method}"
        CrossStub.refresh(:file => $cache_file)
        log "(2) EchoServer::EM#receive_data ... completes stubs refresh"
        klass, method, *args = klass_and_method.split('.')
        konstants = klass.split(/::/)
        if konstants.last.eql?('new')
          konstants.slice!(-1)
          konst = konstants.inject(Object) { |const_train, const| const_train.const_get(const) }
          log "(3) EchoServer::EM#receive_data ... parses arguments to:",
          "    * konst  ... #{konst}",
          "    * method ... #{method}",
          "    * args   ... #{args.inspect}"
          value = args.empty? ? konst::new.send(method) :
            konst::new.send(method, *args) rescue $!.message
        else
          konst = konstants.inject(Object) { |const_train, const| const_train.const_get(const) }
          log "(3) EchoServer::EM#receive_data ... parses arguments to:",
          "    * konst  ... #{konst}",
          "    * method ... #{method}",
          "    * args   ... #{args.inspect}"
          value = args.empty? ? konst.send(method) :
            konst.send(method, *args) rescue $!.message
        end
        log "(4) EchoServer::EM#receive_data ... returns: #{value.inspect}"
        send_data(Marshal.dump(value))
        log "(5) EchoServer::EM#receive_data ... end"
      end

      def log(*msg)
        $logger << [msg, ""].flatten.join("\n")
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
