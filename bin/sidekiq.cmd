@echo off
echo Iniciando Sidekiq para Cinelog...
echo.
echo Certifique-se de que o Redis esta rodando!
echo.
bundle exec sidekiq -C config/sidekiq.yml
