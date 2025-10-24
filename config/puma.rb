max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Worker mode for production (não use no Windows local)
if ENV.fetch("RAILS_ENV") { "development" } == "production"
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  preload_app!
end

plugin :tmp_restart

