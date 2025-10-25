source 'https://rubygems.org'

ruby '3.3.9'

gem 'rails', '~> 7.0'
gem 'pg', '>= 1.1', '< 2.0'
gem 'puma', '~> 6.0'

# Autenticação e autorização
gem 'devise'
gem 'pundit'

# Paginação
gem 'pagy'

# Uploads
gem 'image_processing', '~> 1.2'

# Busca (opcional)
gem 'pg_search'

# HTTP client
gem 'httparty'

# Email delivery via SendGrid API (100 emails/dia gratuitos - funciona no Render)
gem 'sendgrid-ruby'

# Testes e qualidade
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'pundit-matchers', '~> 3.1'
  gem 'rubocop', require: false
  gem 'dotenv-rails'
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'webdrivers'
  gem 'letter_opener_web', '~> 2.0'  # Preview emails no navegador
end

gem 'sprockets-rails'
gem 'sassc-rails'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
