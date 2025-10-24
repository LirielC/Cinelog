# 🚀 GUIA RÁPIDO - Deploy DigitalOcean App Platform

## ✅ Pré-requisitos Concluídos
- ✅ Código no GitHub: https://github.com/LirielC/Cinelog
- ✅ Procfile criado
- ✅ Puma configurado para produção
- ✅ .dockerignore criado

---

## 📝 Informações Necessárias

### 🔑 Suas Chaves (GUARDE COM SEGURANÇA!)

**SECRET_KEY_BASE:**
```
d7795c9e6ea98d7895d5fe618865eb7f06ddc66dee7f5da66cdbc71986ce1e6e3e258df2ba21ecafd05e40c33e7d30157d35e589229e173d0eb35cdcd294091f
```

**TMDB_API_KEY:**
```
9725ed5f92d7e6eb79c5665132a83060
```

**RAILS_MASTER_KEY:** (será criada automaticamente quando você rodar `rails credentials:edit` no futuro)
```
Por enquanto, use: deixe vazio ou use o SECRET_KEY_BASE acima
```

---

## 🎯 Passos para Deploy no DigitalOcean

### 1. Acesse o App Platform
- URL: https://cloud.digitalocean.com/apps
- Clique em **"Create App"**

### 2. Conecte ao GitHub
- Conecte com sua conta GitHub
- Selecione o repositório: **LirielC/Cinelog**
- Branch: **master** (ou **main**)

### 3. Configure o Web Service
- **Name**: `web`
- **Run Command**: `bundle exec puma -C config/puma.rb`
- **HTTP Port**: `3000`
- **Instance Size**: Basic ($12/mês)

### 4. Adicione o Worker Service
- Clique em **"Add Component"** → **"Worker"**
- **Name**: `worker`
- **Run Command**: `bundle exec sidekiq -C config/sidekiq.yml`
- **Instance Size**: Basic ($12/mês)

### 5. Adicione PostgreSQL
- Clique em **"Add Resource"** → **"Database"**
- Selecione **PostgreSQL**
- **Plan**: Dev Database ($7/mês) ✅ Recomendado para teste

### 6. Adicione Redis
- Clique em **"Add Resource"** → **"Database"**
- Selecione **Redis**
- **Plan**: Basic ($15/mês)

### 7. Configure Variáveis de Ambiente

Copie e cole estas variáveis (já preenchidas para você):

```bash
# Rails
RAILS_ENV=production
RACK_ENV=production
SECRET_KEY_BASE=d7795c9e6ea98d7895d5fe618865eb7f06ddc66dee7f5da66cdbc71986ce1e6e3e258df2ba21ecafd05e40c33e7d30157d35e589229e173d0eb35cdcd294091f

# Database (o DigitalOcean preenche automaticamente)
DATABASE_URL=${db.DATABASE_URL}

# Redis (o DigitalOcean preenche automaticamente)
REDIS_URL=${redis.DATABASE_URL}

# TMDB API
TMDB_API_KEY=9725ed5f92d7e6eb79c5665132a83060

# SMTP Gmail (VOCÊ PRECISA PREENCHER!)
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-de-app-do-gmail

# Configurações adicionais
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

**⚠️ IMPORTANTE - SMTP:**
Para obter a senha do Gmail:
1. Vá em https://myaccount.google.com/apppasswords
2. Crie uma senha de app
3. Use essa senha no `SMTP_PASSWORD`

### 8. Faça o Deploy
- Clique em **"Create Resources"**
- Aguarde 5-10 minutos
- Sua app estará em: `https://sua-app.ondigitalocean.app`

### 9. Após o Deploy - Rodar Migrations
1. No painel do App Platform, vá em **Console**
2. Selecione o service **web**
3. Execute:
```bash
rails db:migrate
rails db:seed
```

---

## 💰 Custo Estimado

| Recurso | Custo Mensal |
|---------|--------------|
| Web Service (Basic) | $12 |
| Worker Service (Basic) | $12 |
| PostgreSQL (Dev) | $7 |
| Redis (Basic) | $15 |
| **TOTAL** | **~$46/mês** |

**💡 Dica para economizar:**
- Use PostgreSQL Dev ($7) para começar
- Pode desabilitar o Worker temporariamente se não usar importação CSV
- Custo mínimo: ~$19/mês (só web + database)

---

## 🆘 Troubleshooting

### Deploy falhou?
1. Veja os logs no painel do App Platform
2. Verifique se todas as variáveis de ambiente estão corretas
3. Confirme que o PostgreSQL está conectado

### App não abre?
1. Rode as migrations no Console
2. Verifique logs de erros
3. Confirme que `DATABASE_URL` está configurado

### Emails não funcionam?
1. Verifique `SMTP_USERNAME` e `SMTP_PASSWORD`
2. Certifique-se que usou senha de app do Gmail (não a senha normal)

---

## 📞 Próximos Passos

1. ✅ Acesse https://cloud.digitalocean.com/apps
2. ✅ Siga os 9 passos acima
3. ✅ Teste sua aplicação
4. ✅ Configure domínio customizado (opcional)

**Boa sorte com o deploy! 🚀**
