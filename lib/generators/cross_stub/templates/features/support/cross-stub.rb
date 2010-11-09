require 'cross-stub'

Before do
  # /////////////////////////////////////////////////////////////////////////////////
  # NOTE: By default, we use file-based cache store for cross-stub. Alternatively,
  # u may wanna try out the other cache stores. Adding new cache store support is
  # super easy, w.r.t actual implementation & testing, just drop me a note at
  # http://github.com/ngty/cross-stub & i'll do it for u, of course FOC lah !!
  # /////////////////////////////////////////////////////////////////////////////////
  #CrossStub.setup :redis => 'localhost:6379/xstub.cache' # requires *redis* gem
  #CrossStub.setup :memcache => 'localhost:11211/xstub.cache' # requires *memcache-client* gem
  CrossStub.setup :file => Rails.root.join('tmp', 'xstub.cache')
end

After do
  CrossStub.clear
end
