require 'rubygems'
require 'eventmachine'
require 'base64'
require File.join(File.dirname(__FILE__), 'class_definitions')

$ruby_id = [
  RUBY_VERSION.gsub(/[^\d]/,''),
  RUBY_PLATFORM =~ /java/i ? 'j' : '',
  RUBY_DESCRIPTION =~ /enterprise/i ? 'e' : ''
].join

$project_root = File.join(File.dirname(__FILE__), '..', '..')
$sleep_time = 2  # may need to increase this depending on ur machine's prowess
$log_file = File.join($project_root, 'tmp', "echoserver-#{$ruby_id}.log")

def cache_stores
  {
    :file => File.join($project_root, 'tmp', "stubbing-#{$ruby_id}.cache"),
    :memcache => "localhost:11211/stubbing-#{$ruby_id}.cache",
    :redis => "localhost:6379/stubbing-#{$ruby_id}.cache",
  }
end

def cache_store(id)
  {(id = :"#{id}") => cache_stores[id]}
end

$LOAD_PATH.unshift(File.join($project_root, 'lib'))
require 'cross-stub'

module EchoClient

  class << self

    attr_accessor :result

    def get(klass_and_method)
      address, port = EchoServer::ADDRESS, EchoServer::PORT
      EventMachine::run do
        (EventMachine::connect(address, port, EM)).
          execute(klass_and_method) {|data| self.result = Marshal.load(Base64.decode64(data)) }
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

  ADDRESS = '127.0.0.1'
  PORT = 10000 + $ruby_id[/(\d+)/,1].to_i + ({'j' => 10, 'e' => 20}[$ruby_id[-1..-1]] || 0)

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

    def log(*msg)
      $logger << [msg, ""].flatten.join("\n")
    end

  end

  private

    module EM
      def receive_data(store_type_and_klass_and_method)
        log "\n"
        log "(1) EchoServer::EM#receive_data ... receives: #{store_type_and_klass_and_method}"

        store_type, klass_and_method = store_type_and_klass_and_method.match(/^(.*?)\/(.*)$/)[1..2]
        CrossStub.refresh(cache_store($prev_store_type)) if $prev_store_type
        CrossStub.refresh(cache_store($prev_store_type = store_type))
        log "(2) EchoServer::EM#receive_data ... completes stubs refresh"

        klass_descrp, method, *args = klass_and_method.split('.')
        is_instance = klass_descrp.end_with?(suffix = '#new')
        klass = klass_descrp.sub(suffix,'').split(/::/).inject(Object){|k,c| k.const_get(c) }
        receiver = is_instance ? klass.new : klass

        log "(3) EchoServer::EM#receive_data ... parses arguments to:",
        "    * receiver ... #{klass}%s" % (is_instance ? "#new" : nil),
        "    * method   ... #{method}",
        "    * args     ... #{args.inspect}"

        value = args.empty? ? receiver.send(method) : receiver.send(method, *args) rescue $!.message

        log "(4) EchoServer::EM#receive_data ... returns: #{value.inspect}"
        send_data(Base64.encode64(Marshal.dump(value)))
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
  rescue
    $logger << $!.inspect
  ensure
    $logger.close
  end
end
