# 🚀 Guia Rápido - Iniciar Sistema com Sidekiq

## ⚡ Início Rápido (3 comandos)

### 1. Iniciar Redis (Terminal 1)
```bash
redis-server
```
Deixe este terminal aberto!

---

### 2. Iniciar Rails (Terminal 2)
```bash
cd c:\Users\Ryzen\Documents\Cinelog
rails server
```
Acesse: http://localhost:3000

---

### 3. Iniciar Sidekiq (Terminal 3)
```bash
cd c:\Users\Ryzen\Documents\Cinelog
.\bin\sidekiq.cmd
```
**OU**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

---

## ✅ Verificar se está tudo funcionando

### Teste 1: Redis
```bash
redis-cli ping
```
**Esperado**: `PONG`

### Teste 2: Rails
Abra o navegador: http://localhost:3000
**Esperado**: Página inicial do Cinelog

### Teste 3: Sidekiq
Abra o navegador: http://localhost:3000/sidekiq (fazer login como admin primeiro)
**Esperado**: Dashboard do Sidekiq

---

## 📝 Testar Importação CSV

### 1. Criar arquivo de teste
Crie `teste.csv`:
```csv
titulo,sinopse,ano_lancamento,duracao_minutos,diretor,categorias
Matrix,Neo descobre a verdade,1999,136,Wachowski,Ação
Inception,Sonhos dentro de sonhos,2010,148,Nolan,Thriller
```

### 2. Fazer upload
1. Acesse: http://localhost:3000/importacoes/new
2. Selecione o arquivo `teste.csv`
3. Clique em "Importar Filmes"

### 3. Verificar processamento
- **Na tela**: Status muda de "pendente" → "processando" → "concluído"
- **No terminal Sidekiq**: Logs do processamento
- **No e-mail**: Notificação com resumo

---

## 🎯 Dashboard Sidekiq

Acesse: http://localhost:3000/sidekiq

### O que você verá:
- 📊 Jobs processados
- ⏳ Jobs na fila
- ❌ Jobs com falha
- 📈 Gráficos de performance
- 🔄 Retry de jobs falhados

**Nota**: Apenas usuários **admin** têm acesso!

---

## 🛑 Parar Tudo

```bash
# No terminal do Redis
Ctrl + C

# No terminal do Rails
Ctrl + C

# No terminal do Sidekiq
Ctrl + C
```

---

## 🔧 Troubleshooting

### Redis não inicia
```bash
# Verificar se Redis está instalado
redis-cli --version

# Se não estiver instalado (Windows):
choco install redis-64
```

### Sidekiq não processa jobs
```bash
# Verificar se Sidekiq está rodando
ps aux | grep sidekiq  # Linux/Mac
Get-Process | Select-String sidekiq  # Windows PowerShell

# Limpar filas (Rails console)
rails console
Sidekiq::Queue.all.each(&:clear)
```

### E-mails não são enviados
Verifique configuração SMTP em `config/environments/development.rb`

---

## 📚 Documentação Completa

- **Sidekiq**: Ver `SIDEKIQ_SETUP.md`
- **Importação CSV**: Ver `IMPORTACAO_CSV.md`
- **SMTP**: Ver `CONFIGURACAO_SMTP.md`

---

## 🎉 Pronto!

Agora você tem:
- ✅ Sistema de importação em massa funcionando
- ✅ Processamento em background com Sidekiq
- ✅ Notificações por e-mail automáticas
- ✅ Dashboard de monitoramento

**Bom trabalho!** 🚀
