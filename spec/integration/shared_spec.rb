require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'includes')

shared 'has standard setup' do
  before { CrossStub.setup(cache_store(@store_type)) }
  after { CrossStub.clear }
end

shared 'has current process setup' do
  behaves_like 'has standard setup'
  before { @call = Object.method(:do_local_method_call) }
end

shared 'has other process setup' do

  behaves_like 'has standard setup'

  before do
    @call = lambda do |method_call_args|
      do_remote_method_call("%s/%s" % [@store_type, method_call_args])
    end
    $service_started ||= (
      ENV['FORK_SERVER'] != 'false' && (
        Otaku.start do |data|
          @@_not_isolated_vars = :all # we don't wanna isolate any contextual references
          require File.join(File.dirname(__FILE__), '..', 'includes')
          store_type, method_call_args = data.match(/^(.*?)\/(.*)$/)[1..2]
          CrossStub.refresh(cache_store($prev_store_type)) if $prev_store_type
          CrossStub.refresh(cache_store($prev_store_type = store_type))
          do_local_method_call(method_call_args) rescue $!.message
        end
      ) ; true
    )
  end

end

at_exit do
  ENV['FORK_SERVER'] != 'false' && $service_started && Otaku.stop
end
