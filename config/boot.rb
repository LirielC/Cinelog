ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# bootsnap is optional; don't fail if it's not available
begin
  require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
rescue LoadError
  # Bootsnap not available; continue without it.
end
