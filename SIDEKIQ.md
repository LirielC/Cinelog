# ⚙️ Guia Sidekiq - Background Jobs

Documentação completa sobre o sistema de background jobs do Cinelog usando Sidekiq.

---

## 📋 Visão Geral

O Cinelog usa **ActiveJob** com dois adapters diferentes:

- **Development (Local):** `:async` - processamento em memória, sem Redis
- **Production:** `:sidekiq` - processamento robusto com Redis

Isso permite desenvolver localmente sem instalar Redis, mas ter performance em produção.

---

## 🏗️ Arquitetura

### **Jobs Implementados:**

1. **ImportacaoJob** (`app/jobs/importacao_job.rb`)
   - Processa importação CSV de filmes em background
   - Busca dados no TMDB
   - Envia email de notificação
   - Fila: `importacoes`

2. **Mailers** (via ActionMailer)
   - Emails de notificação
   - Fila: `mailers` (prioridade alta)

### **Configuração de Filas:**

| Fila | Prioridade | Uso |
|------|-----------|-----|
| `mailers` | 10 | Emails (alta prioridade) |
| `importacoes` | 5 | Importações CSV |
| `default` | 1 | Jobs gerais |

---

## 🚀 Setup Local (Opcional)

Por padrão, o desenvolvimento usa `:async` e **não requer Redis**. Mas se quiser usar Sidekiq localmente:

### **1. Instale Redis**

#### **Windows:**
```powershell
# Opção 1: Via Chocolatey
choco install redis-64

# Opção 2: Download manual
# https://github.com/microsoftarchive/redis/releases
# Baixe o .msi e instale
```

#### **Linux/Mac:**
```bash
# Ubuntu/Debian
sudo apt-get install redis-server

# Mac
brew install redis
```

### **2. Inicie Redis**

```powershell
# Windows
redis-server

# Linux/Mac
redis-server

# Verificar se está rodando
redis-cli ping
# Deve retornar: PONG
```

### **3. Configure o Projeto**

#### **a) Descomente linha no `config/routes.rb`:**

```ruby
# Antes:
# require 'sidekiq/web'
# mount Sidekiq::Web => '/sidekiq'

# Depois:
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
```

#### **b) Comente override em `config/environments/development.rb`:**

```ruby
# Antes:
config.active_job.queue_adapter = :async

# Depois (comente a linha):
# config.active_job.queue_adapter = :async
```

#### **c) Adicione Redis URL ao `.env`:**

```env
REDIS_URL=redis://localhost:6379/1
```

### **4. Inicie Sidekiq**

```powershell
# Em um terminal separado
bundle exec sidekiq -C config/sidekiq.yml
```

Você verá output similar a:

```
         m,
         `$b
    .ss,  $$:         .,d$
    `$$P,d$P'    .,md$P"'
     ,$$$$$b/md$$$P^'
   .d$$$$$$/$$$P'
   $$^' `"/$$$'       ____  _     _      _    _
   $:     ,$$:       / ___|(_) __| | ___| | _(_) __ _
   `b     :$$        \___ \| |/ _` |/ _ \ |/ / |/ _` |
          $$:         ___) | | (_| |  __/   <| | (_| |
          $$         |____/|_|\__,_|\___|_|\_\_|\__, |
        .d$$                                        |_|

2025-10-25T18:00:00.000Z 12345 TID-abc INFO: Booted Rails 7.x.x application
2025-10-25T18:00:00.000Z 12345 TID-abc INFO: Running in ruby 3.3.9
2025-10-25T18:00:00.000Z 12345 TID-abc INFO: Starting processing, hit Ctrl-C to stop
```

### **5. Acesse Dashboard**

Com Sidekiq rodando, acesse:

**http://localhost:3000/sidekiq**

**Autenticação:** Apenas usuários **Admin** podem acessar (configurado via Pundit)

---

## 📊 Dashboard Sidekiq

O dashboard web fornece:

### **Informações em Tempo Real:**
- ✅ Jobs processados/falhados
- ✅ Filas e suas estatísticas
- ✅ Workers ativos
- ✅ Jobs agendados (scheduled)
- ✅ Jobs em retry

### **Ações Disponíveis:**
- 🔄 Reprocessar jobs falhados
- 🗑️ Deletar jobs
- ⏸️ Pausar/Despausar filas
- 📊 Ver detalhes de cada job

### **Screenshot típico:**
```
Sidekiq 7.x.x
Uptime: 1h 23m
Processed: 150
Failed: 2
Busy: 1
Enqueued: 5
Retries: 0
Scheduled: 0
Dead: 0
```

---

## 🔧 Configuração

### **config/sidekiq.yml**

```yaml
---
:queues:
  - [mailers, 10]      # Alta prioridade
  - [importacoes, 5]   # Média prioridade
  - [default, 1]       # Baixa prioridade

:concurrency: 5        # 5 jobs simultâneos

:timeout: 25           # Timeout padrão (segundos)

:max_retries: 3        # Tentar 3x antes de falhar

production:
  :concurrency: 10     # Mais workers em produção
```

### **Explicação:**

- **queues:** Define ordem de prioridade de processamento
- **concurrency:** Número de threads simultâneas
- **timeout:** Tempo máximo para job completar
- **max_retries:** Tentativas automáticas em caso de falha

---

## 💻 Uso em Desenvolvimento

### **Modo Async (Padrão - Sem Redis):**

```ruby
# Jobs são executados em background, mas em memória
ImportacaoJob.perform_later(importacao.id)

# Resultado: Job executado em thread separada, sem necessidade de Sidekiq
```

**Vantagens:**
- ✅ Sem necessidade de Redis
- ✅ Setup simples
- ✅ Ideal para desenvolvimento

**Desvantagens:**
- ❌ Jobs perdidos se servidor reiniciar
- ❌ Sem dashboard visual
- ❌ Performance limitada

### **Modo Sidekiq (Com Redis):**

```ruby
# Jobs enfileirados no Redis e processados por workers Sidekiq
ImportacaoJob.perform_later(importacao.id)

# Resultado: Job adicionado ao Redis, processado por worker separado
```

**Vantagens:**
- ✅ Jobs persistidos no Redis
- ✅ Dashboard web para monitoramento
- ✅ Retry automático
- ✅ Performance superior
- ✅ Simula ambiente de produção

---

## 🚀 Produção

### **Requisitos:**

1. ✅ **Redis** rodando
2. ✅ **REDIS_URL** configurada
3. ✅ **Sidekiq worker** iniciado

### **Deploy no Render:**

O `Procfile` já está configurado:

```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
```

**Passos:**

1. **Adicione Redis Addon** no Render
   - Render provisiona automaticamente
   - Variável `REDIS_URL` é criada

2. **Configure Worker**
   - Render detecta `Procfile`
   - Cria processo `worker` automaticamente

3. **Monitore Jobs**
   - Acesse: `https://seu-app.onrender.com/sidekiq`
   - Login como admin para ver dashboard

### **Deploy no Heroku:**

```powershell
# Adicionar Redis
heroku addons:create heroku-redis:mini

# Escalar worker (inicialmente 0)
heroku ps:scale worker=1

# Ver logs
heroku logs --tail --ps worker
```

---

## 🧪 Testando Jobs

### **Console Rails:**

```ruby
# Enfileirar job manualmente
ImportacaoJob.perform_later(1)

# Ver jobs pendentes (com Sidekiq)
Sidekiq::Queue.new('importacoes').size

# Ver estatísticas
Sidekiq::Stats.new
```

### **RSpec:**

```ruby
# spec/jobs/importacao_job_spec.rb
require 'rails_helper'

RSpec.describe ImportacaoJob, type: :job do
  it 'enfileira na fila importacoes' do
    expect {
      ImportacaoJob.perform_later(1)
    }.to have_enqueued_job(ImportacaoJob)
      .on_queue('importacoes')
      .with(1)
  end
end
```

---

## 📈 Monitoramento

### **Logs do Sidekiq:**

```powershell
# Ver logs em tempo real
Get-Content log/sidekiq.log -Wait

# Grep por erros
Select-String -Path log/sidekiq.log -Pattern "ERROR"
```

### **Métricas Importantes:**

- **Processed:** Total de jobs executados com sucesso
- **Failed:** Jobs que falharam após todas tentativas
- **Busy:** Workers atualmente processando
- **Enqueued:** Jobs aguardando processamento
- **Retries:** Jobs aguardando nova tentativa
- **Dead:** Jobs que falharam definitivamente

---

## 🐛 Troubleshooting

### **Erro: "ECONNREFUSED - conexão recusada"**

**Causa:** Redis não está rodando

**Solução:**
```powershell
redis-server
```

### **Erro: "Errno::ENOENT: No such file or directory - redis-cli"**

**Causa:** Redis não instalado

**Solução:** Instale Redis (veja seção Setup)

### **Jobs não processam**

**Causa:** Sidekiq worker não está rodando

**Solução:**
```powershell
bundle exec sidekiq -C config/sidekiq.yml
```

### **Dashboard /sidekiq não acessível**

**Causa 1:** Linha comentada em `routes.rb`

**Solução:** Descomente:
```ruby
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
```

**Causa 2:** Usuário não é admin

**Solução:** Faça login como admin (`admin@cinelog.com` / `admin123`)

### **Jobs executam mas não vejo no dashboard**

**Causa:** Usando `:async` adapter

**Solução:** Troque para `:sidekiq` (veja seção Setup Local)

---

## 📚 Documentação Adicional

- **Sidekiq Wiki:** https://github.com/sidekiq/sidekiq/wiki
- **Best Practices:** https://github.com/sidekiq/sidekiq/wiki/Best-Practices
- **Active Job Guide:** https://guides.rubyonrails.org/active_job_basics.html

---

## 💡 Dicas

### **Performance:**

- Use `perform_later` (não `perform_now`) para jobs pesados
- Divida jobs grandes em jobs menores
- Use bulk enqueuing para muitos jobs:
  ```ruby
  Sidekiq::Client.push_bulk(
    'class' => ImportacaoJob,
    'args' => [[1], [2], [3]]
  )
  ```

### **Debugging:**

```ruby
# Adicione logging nos jobs
class ImportacaoJob < ApplicationJob
  def perform(importacao_id)
    Rails.logger.info "🔄 Iniciando ImportacaoJob ##{importacao_id}"
    # ... código ...
    Rails.logger.info "✅ ImportacaoJob ##{importacao_id} concluído"
  end
end
```

### **Monitoramento em Produção:**

Considere usar:
- **Sidekiq Enterprise** (pago): Features avançadas
- **Redis Commander**: GUI para visualizar Redis
- **New Relic / DataDog**: APM com suporte Sidekiq

---

**Pronto para processar jobs em background! ⚡**
