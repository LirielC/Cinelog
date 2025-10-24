require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_storage/engine'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module Cinelog
  class Application < Rails::Application
    config.load_defaults 7.0
    # Timezone and locale configs
    config.time_zone = 'Brasilia'
    config.i18n.default_locale = :'pt-BR'
    config.i18n.available_locales = [:'pt-BR']
    
    # Usar async adapter (funciona sem Redis)
    config.active_job.queue_adapter = :async
  end
end
