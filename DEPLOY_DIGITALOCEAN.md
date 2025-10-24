# 🚀 Deploy no DigitalOcean - Guia Completo

## 📋 Opções de Deploy

### Opção 1: App Platform (Recomendado - Mais Fácil) ⭐
- **Vantagens**: Deploy automático, escalável, gerenciado
- **Custo**: ~$12/mês (Basic)
- **Complexidade**: ⭐ Fácil

### Opção 2: Droplet + Dokku (Intermediário)
- **Vantagens**: Controle total, mais barato
- **Custo**: ~$6/mês
- **Complexidade**: ⭐⭐ Médio

### Opção 3: Droplet Manual (Avançado)
- **Vantagens**: Máximo controle
- **Custo**: ~$6/mês
- **Complexidade**: ⭐⭐⭐ Difícil

---

## 🎯 Opção 1: App Platform (RECOMENDADO)

### Passo 1: Preparar o Projeto

#### 1.1. Criar arquivo `Procfile`
```ruby
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
```

#### 1.2. Configurar Puma para produção
Edite `config/puma.rb`:
```ruby
# config/puma.rb
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

preload_app!

plugin :tmp_restart
```

#### 1.3. Adicionar gems de produção
No `Gemfile`, certifique-se de ter:
```ruby
group :production do
  gem 'pg'  # Já tem
end
```

#### 1.4. Criar `.dockerignore` (opcional)
```
.git
log/*
tmp/*
*.log
.env
```

---

### Passo 2: Fazer Push para GitHub

```bash
# Se ainda não tem repositório Git
git init
git add .
git commit -m "Preparar para deploy no DigitalOcean"

# Criar repositório no GitHub e fazer push
git remote add origin https://github.com/SEU-USUARIO/cinelog.git
git branch -M main
git push -u origin main
```

---

### Passo 3: Configurar no DigitalOcean App Platform

#### 3.1. Criar App
1. Acesse: https://cloud.digitalocean.com/apps
2. Clique em **"Create App"**
3. Conecte com **GitHub**
4. Selecione o repositório **cinelog**
5. Selecione branch **main**

#### 3.2. Configurar Services

**Web Service:**
- **Name**: `web`
- **Source Directory**: `/`
- **Build Command**: (deixe vazio, usará Bundler)
- **Run Command**: `bundle exec puma -C config/puma.rb`
- **HTTP Port**: `3000`
- **Instance Size**: Basic ($12/mês)
- **Instance Count**: 1

**Worker Service:**
- Clique em **"Add Component"** → **"Worker"**
- **Name**: `worker`
- **Run Command**: `bundle exec sidekiq -C config/sidekiq.yml`
- **Instance Size**: Basic ($12/mês)
- **Instance Count**: 1

#### 3.3. Adicionar Database (PostgreSQL)
1. Clique em **"Add Resource"** → **"Database"**
2. Selecione **PostgreSQL**
3. **Plan**: Dev Database ($7/mês) ou Basic ($15/mês)
4. Clique em **"Add"**

#### 3.4. Adicionar Redis
1. Clique em **"Add Resource"** → **"Database"**
2. Selecione **Redis**
3. **Plan**: Basic ($15/mês)
4. Clique em **"Add"**

#### 3.5. Configurar Variáveis de Ambiente
Clique em **"Environment Variables"** e adicione:

```bash
# Rails
RAILS_ENV=production
RAILS_MASTER_KEY=<copie de config/master.key>
RACK_ENV=production
SECRET_KEY_BASE=<gere com: rails secret>

# Database (auto-conectado pelo DO)
DATABASE_URL=${db.DATABASE_URL}

# Redis (auto-conectado pelo DO)
REDIS_URL=${redis.DATABASE_URL}

# SMTP (Gmail)
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-de-app

# Configurações adicionais
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

**🔑 Como gerar RAILS_MASTER_KEY:**
```bash
# No seu projeto local
cat config/master.key
```

**🔑 Como gerar SECRET_KEY_BASE:**
```bash
rails secret
```

---

### Passo 4: Deploy

1. Revise todas as configurações
2. Clique em **"Create Resources"**
3. Aguarde ~5-10 minutos para o build
4. Acesso em: `https://sua-app.ondigitalocean.app`

---

### Passo 5: Configurações Pós-Deploy

#### 5.1. Rodar Migrações
Na interface do App Platform:
1. Vá em **Console**
2. Selecione o service **web**
3. Execute:
```bash
rails db:migrate
rails db:seed  # Se tiver seeds
```

#### 5.2. Configurar Domínio Customizado (Opcional)
1. Vá em **Settings** → **Domains**
2. Adicione seu domínio
3. Configure DNS no seu registrador

---

## 🎯 Opção 2: Droplet + Dokku (Mais Barato)

### Custo Total: ~$10/mês
- Droplet: $6/mês (1GB RAM)
- Managed PostgreSQL: $15/mês (ou PostgreSQL no Droplet: $0)
- Managed Redis: $15/mês (ou Redis no Droplet: $0)

### Passo 1: Criar Droplet

1. Acesse: https://cloud.digitalocean.com/droplets/new
2. Escolha:
   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Basic - $6/mês (1GB RAM, 25GB SSD)
   - **Datacenter**: Escolha o mais próximo
   - **Authentication**: SSH Key (recomendado)
3. Clique em **Create Droplet**

### Passo 2: Instalar Dokku

Conecte via SSH:
```bash
ssh root@SEU_IP_DO_DROPLET
```

Instale Dokku:
```bash
# Instalar Dokku
wget -NP . https://dokku.com/install/v0.32.0/bootstrap.sh
sudo DOKKU_TAG=v0.32.0 bash bootstrap.sh

# Configurar domínio
dokku domains:set-global SEUDOMINIO.com

# Instalar plugins
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
sudo dokku plugin:install https://github.com/dokku/dokku-redis.git redis
```

### Passo 3: Criar App no Dokku

```bash
# Criar aplicação
dokku apps:create cinelog

# Criar banco PostgreSQL
dokku postgres:create cinelog-db
dokku postgres:link cinelog-db cinelog

# Criar Redis
dokku redis:create cinelog-redis
dokku redis:link cinelog-redis cinelog

# Configurar variáveis de ambiente
dokku config:set cinelog RAILS_ENV=production
dokku config:set cinelog RAILS_MASTER_KEY=<sua-master-key>
dokku config:set cinelog SECRET_KEY_BASE=$(rails secret)
dokku config:set cinelog SMTP_USERNAME=seu-email@gmail.com
dokku config:set cinelog SMTP_PASSWORD=sua-senha
```

### Passo 4: Deploy via Git

No seu projeto local:
```bash
# Adicionar remote do Dokku
git remote add dokku dokku@SEU_IP:cinelog

# Fazer push
git push dokku main

# Rodar migrações
ssh dokku@SEU_IP run cinelog rails db:migrate
```

---

## 🎯 Opção 3: Droplet Manual (Máximo Controle)

### Passo 1: Criar Droplet
- Ubuntu 22.04 LTS
- 2GB RAM recomendado ($12/mês)

### Passo 2: Instalar Dependências

```bash
# Conectar via SSH
ssh root@SEU_IP

# Atualizar sistema
apt update && apt upgrade -y

# Instalar Ruby
apt install -y curl gpg
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 3.3.9
rvm use 3.3.9 --default

# Instalar PostgreSQL
apt install -y postgresql postgresql-contrib libpq-dev

# Instalar Redis
apt install -y redis-server

# Instalar Node.js (para assets)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Instalar Nginx
apt install -y nginx

# Instalar dependências Rails
apt install -y build-essential git-core
```

### Passo 3: Configurar Banco de Dados

```bash
# Criar usuário PostgreSQL
sudo -u postgres createuser -s cinelog_user
sudo -u postgres psql
postgres=# \password cinelog_user
# Digite a senha
postgres=# CREATE DATABASE cinelog_production;
postgres=# \q
```

### Passo 4: Deploy da Aplicação

```bash
# Criar usuário deploy
adduser deploy
usermod -aG sudo deploy

# Trocar para usuário deploy
su - deploy

# Clonar projeto
git clone https://github.com/SEU-USUARIO/cinelog.git
cd cinelog

# Instalar gems
bundle install --without development test

# Configurar variáveis de ambiente
nano .env
# Adicione:
# RAILS_ENV=production
# DATABASE_URL=postgresql://cinelog_user:senha@localhost/cinelog_production
# REDIS_URL=redis://localhost:6379/0
# SECRET_KEY_BASE=$(rails secret)
# etc...

# Compilar assets
RAILS_ENV=production rails assets:precompile

# Rodar migrações
RAILS_ENV=production rails db:migrate
```

### Passo 5: Configurar Systemd (Puma + Sidekiq)

**Puma Service** (`/etc/systemd/system/puma.service`):
```ini
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/cinelog
ExecStart=/usr/local/rvm/gems/ruby-3.3.9/bin/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
```

**Sidekiq Service** (`/etc/systemd/system/sidekiq.service`):
```ini
[Unit]
Description=Sidekiq Background Worker
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/cinelog
ExecStart=/usr/local/rvm/gems/ruby-3.3.9/bin/bundle exec sidekiq -C config/sidekiq.yml
Restart=always

[Install]
WantedBy=multi-user.target
```

**Ativar serviços:**
```bash
sudo systemctl enable puma sidekiq
sudo systemctl start puma sidekiq
sudo systemctl status puma sidekiq
```

### Passo 6: Configurar Nginx

Edite `/etc/nginx/sites-available/cinelog`:
```nginx
upstream puma {
  server unix:///home/deploy/cinelog/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name seudominio.com www.seudominio.com;

  root /home/deploy/cinelog/public;

  try_files $uri/index.html $uri @puma;

  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

**Ativar site:**
```bash
sudo ln -s /etc/nginx/sites-available/cinelog /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Passo 7: SSL com Let's Encrypt

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d seudominio.com -d www.seudominio.com
```

---

## 📊 Comparação de Custos

| Opção | Custo Mensal | Facilidade | Escalabilidade |
|-------|--------------|------------|----------------|
| **App Platform** | ~$40 (tudo gerenciado) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Dokku** | ~$6-20 | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Manual** | ~$12-18 | ⭐⭐ | ⭐⭐⭐⭐ |

---

## ✅ Checklist Pré-Deploy

- [ ] Código no GitHub/GitLab
- [ ] `Procfile` criado
- [ ] `config/master.key` anotada
- [ ] Variáveis de ambiente definidas
- [ ] SMTP configurado (Gmail App Password)
- [ ] Seeds preparados (se necessário)
- [ ] Migrações testadas localmente
- [ ] Assets precompilados testados

---

## 🔧 Troubleshooting

### Erro: "We're sorry, but something went wrong"
```bash
# Ver logs
dokku logs cinelog -t  # Dokku
# ou no App Platform: Console → Logs

# Rodar migrações
dokku run cinelog rails db:migrate
```

### Erro de Assets
```bash
# Recompilar assets
RAILS_ENV=production rails assets:precompile
```

### Sidekiq não processa jobs
- Verifique se REDIS_URL está configurado
- Veja logs do worker
- Teste conexão Redis

---

## 📚 Recursos Adicionais

- [DigitalOcean App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [Dokku Documentation](https://dokku.com/docs/deployment/application-deployment/)
- [Rails Production Guide](https://guides.rubyonrails.org/configuring.html#running-in-production)

---

## 💡 Dica Final

**Para iniciantes**: Use **App Platform**! É mais caro mas poupa horas de configuração e dor de cabeça.

**Para experientes**: Use **Dokku** para ter controle com facilidade.

**Para experts**: Configure manualmente para máximo controle.

---

**Qual opção você prefere? Posso te ajudar com os próximos passos! 🚀**
