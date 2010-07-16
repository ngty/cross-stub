require 'rubygems'
require 'eventmachine'
require File.join(File.dirname(__FILE__), 'includes')

module EchoClient

  ADDRESS = ECHO_SERVER_HOST
  PORT = ECHO_SERVER_PORT

  class << self
    def get(klass_and_method)
      EventMachine::run do
        (EventMachine::connect(ADDRESS, PORT, EM)).
          execute(klass_and_method){|data| @result = Marshal.load(Base64.decode64(data)) }
      end
      @result
    end
  end

  private

    module EM
      def receive_data(data)
        @callback.call(data)
        EventMachine::stop_event_loop
      end
      def execute(method, &blk)
        @callback = blk
        send_data(method)
      end
    end

end

module EchoServer

  ADDRESS = ECHO_SERVER_HOST
  PORT = ECHO_SERVER_PORT
  LOG = ECHO_SERVER_LOG
  WAIT_TIME = ECHO_SERVER_INIT_WAIT_TIME

  class << self

    def log(*msg)
      (@logger ||= (
        require 'logger'
        Logger.new(LOG)
      )) << [msg, ""].flatten.join("\n")
    end

    def cleanup
      @logger.close
    end

    def start(other_process=false)
      unless other_process
        @process = IO.popen("ruby #{__FILE__}",'r')
        sleep WAIT_TIME
      else
        log 'Starting echo service at %s:%s (#%s)' % [ADDRESS, PORT, Process.pid]
        EventMachine::run { EventMachine::start_server(ADDRESS, PORT, EM) }
      end
    end

    def stop
      Process.kill('SIGHUP', @process.pid) if @process
    end

  end

  private

    module EM

      def receive_data(store_type_and_klass_and_method_and_args)
        log "\n"
        log "(1) EchoServer::EM#receive_data ... receives: #{store_type_and_klass_and_method_and_args}"

        store_type, klass_and_method_and_args =
          store_type_and_klass_and_method_and_args.match(/^(.*?)\/(.*)$/)[1..2]

        CrossStub.refresh(cache_store($prev_store_type)) if $prev_store_type
        CrossStub.refresh(cache_store($prev_store_type = store_type))
        log "(2) EchoServer::EM#receive_data ... completes stubs refresh"

        klass, is_instance, method, args = parse_call_args(klass_and_method_and_args)
        log "(3) EchoServer::EM#receive_data ... parses arguments to:",
          "    * receiver ... #{klass}%s" % (is_instance ? "#new" : nil),
          "    * method   ... #{method}",
          "    * args     ... #{args.inspect}"
        value = do_local_method_call(klass_and_method_and_args) rescue $!.message

        log "(4) EchoServer::EM#receive_data ... returns: #{value.inspect}"
        send_data(Base64.encode64(Marshal.dump(value)))
        log "(5) EchoServer::EM#receive_data ... end"
      end

      def log(*msg)
        EchoServer.log(*msg)
      end

    end

end

if $0 == __FILE__
  begin
    EchoServer.start(true)
  rescue
    EchoServer.log "#{$!.inspect}\n"
  ensure
    EchoServer.cleanup
  end
end
