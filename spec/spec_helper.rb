require 'rubygems'
require 'bacon'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cache-stub'

Bacon.summary_on_exit

shared 'has standard setup' do
  before do
    CacheStub.setup(:file => '/tmp/cachemock.cache')
  end
  after do
    CacheStub.clear
  end
end

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

