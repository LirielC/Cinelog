# 🚀 Guia de Setup Local - Cinelog

Este guia fornece instruções detalhadas para configurar e rodar o projeto Cinelog em sua máquina local.

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

### Obrigatórios:
- **Ruby** 3.3.9 ou superior
  - Verifique: `ruby --version`
  - Instale via [rbenv](https://github.com/rbenv/rbenv) ou [RVM](https://rvm.io/)
  
- **Rails** 7.x
  - Instale: `gem install rails`
  - Verifique: `rails --version`

- **PostgreSQL** 12+
  - Windows: [Download](https://www.postgresql.org/download/windows/)
  - Verifique: `psql --version`
  
- **Bundler** 2.x
  - Instale: `gem install bundler`
  - Verifique: `bundle --version`

- **Node.js** 16+ e **Yarn**
  - Node: [Download](https://nodejs.org/)
  - Yarn: `npm install -g yarn`
  - Verifique: `node --version && yarn --version`

### Opcional (para processamento de imagens):
- **ImageMagick** ou **libvips**
  - Windows ImageMagick: [Download](https://imagemagick.org/script/download.php)

### Opcional (para background jobs em produção):
- **Redis** 4+
  - Windows: [Download](https://github.com/microsoftarchive/redis/releases)
  - Verifique: `redis-cli --version`

---

## 🔧 Instalação Passo a Passo

### **1. Clone o Repositório**

```powershell
git clone https://github.com/LirielC/Cinelog.git
cd Cinelog
```

### **2. Instale as Dependências**

```powershell
# Instalar gems Ruby
bundle install

# Instalar dependências JavaScript
yarn install
```

### **3. Configure as Variáveis de Ambiente**

Crie um arquivo `.env` na raiz do projeto:

```powershell
# Criar arquivo .env
New-Item -Path .env -ItemType File
```

Adicione o seguinte conteúdo ao `.env`:

```env
# ==========================================
# CONFIGURAÇÕES DE DESENVOLVIMENTO LOCAL
# ==========================================

# Banco de Dados PostgreSQL
DATABASE_URL=postgresql://postgres:suasenha@localhost:5432/cinelog_development

# TMDB API (obtenha em https://www.themoviedb.org/settings/api)
TMDB_API_KEY=sua_chave_tmdb_aqui

# Email (SMTP Gmail para desenvolvimento)
GMAIL_USERNAME=seu.email@gmail.com
GMAIL_PASSWORD=sua_senha_de_app_aqui

# Redis (opcional - apenas se usar Sidekiq localmente)
# REDIS_URL=redis://localhost:6379/1

# SendGrid (opcional - usado em produção)
# SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxx
```

**Importante:** 
- Adicione `.env` ao `.gitignore` (já está incluído)
- Nunca commite credenciais reais!

### **4. Configure o Banco de Dados**

#### **Opção A: Usando DATABASE_URL (Recomendado)**

Já configurado no `.env` acima.

#### **Opção B: Editando database.yml**

Edite `config/database.yml`:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: cinelog_development
  pool: 5
  username: postgres
  password: suasenha
  host: localhost
  port: 5432
```

### **5. Crie e Migre o Banco de Dados**

```powershell
# Criar banco de dados
bin/rails db:create

# Executar migrations
bin/rails db:migrate

# Popular com dados de exemplo (OPCIONAL mas recomendado)
bin/rails db:seed
```

**O que o seed cria:**
- 3 usuários (admin, moderador, usuário)
- 5 categorias de filmes
- 10 filmes com informações completas
- Comentários de exemplo

### **6. Inicie o Servidor**

```powershell
# Método 1: Usar script do Rails
bin/rails server

# Método 2: Usar bundle exec
bundle exec rails server

# Método 3: Porta customizada
bin/rails server -p 3001
```

O servidor iniciará em **http://localhost:3000**

---

## 🔐 Acessando o Sistema

Após executar `rails db:seed`, você pode fazer login com:

| Usuário | Email | Senha | Papel |
|---------|-------|-------|-------|
| Admin | `admin@cinelog.com` | `admin123` | Administrador |
| Moderador | `moderador@cinelog.com` | `moderador123` | Moderador |
| Usuário | `usuario@cinelog.com` | `usuario123` | Usuário comum |

---

## 🔍 Verificando a Instalação

Execute estes comandos para verificar se tudo está funcionando:

```powershell
# Verificar gems instaladas
bundle check

# Verificar conexão com banco de dados
bin/rails db:version

# Verificar rotas do Rails
bin/rails routes

# Executar console Rails (para testes)
bin/rails console
```

No console Rails, teste:

```ruby
# Verificar usuários
Usuario.count  # Deve retornar 3

# Verificar filmes
Filme.count    # Deve retornar 10

# Verificar categorias
Categoria.count  # Deve retornar 5
```

Digite `exit` para sair do console.

---

## 📧 Configurando Email (Opcional)

### **Para Gmail:**

1. **Habilite autenticação de 2 fatores** no Gmail
2. **Gere senha de app:**
   - Acesse: https://myaccount.google.com/apppasswords
   - App: "Mail"
   - Device: "Windows Computer"
   - Copie a senha gerada (16 caracteres sem espaços)
3. **Adicione ao `.env`:**
   ```env
   GMAIL_USERNAME=seu.email@gmail.com
   GMAIL_PASSWORD=abcd efgh ijkl mnop  # Senha de 16 caracteres
   ```

**Nota:** Em desenvolvimento, emails não são enviados de verdade. Eles aparecem nos logs do servidor.

---

## 🎬 Configurando TMDB API (Recomendado)

Para busca automática de informações de filmes:

1. **Crie conta gratuita:**
   - Acesse: https://www.themoviedb.org/signup
   
2. **Solicite API Key:**
   - Vá em: Settings → API
   - Request API Key (gratuita)
   - Aceite os termos
   
3. **Copie a API Key (v3 auth)**

4. **Adicione ao `.env`:**
   ```env
   TMDB_API_KEY=sua_chave_de_32_caracteres_aqui
   ```

5. **Reinicie o servidor Rails**

Agora você pode buscar filmes automaticamente ao criar novos registros!

---

## 🐛 Troubleshooting Comum

### **Erro: "could not connect to server"**

**Causa:** PostgreSQL não está rodando

**Solução:**
```powershell
# Windows: Verifique serviço PostgreSQL
Get-Service -Name postgresql*

# Se não estiver rodando, inicie:
Start-Service postgresql-x64-14  # Ajuste versão
```

### **Erro: "PG::ConnectionBad: fe_sendauth: no password supplied"**

**Causa:** Credenciais incorretas do PostgreSQL

**Solução:**
- Verifique `DATABASE_URL` no `.env`
- Ou ajuste `config/database.yml`

### **Erro: "Yarn: command not found"**

**Causa:** Yarn não está instalado

**Solução:**
```powershell
npm install -g yarn
```

### **Erro: "bundler: command not found: rails"**

**Causa:** Rails não está instalado ou não está no PATH

**Solução:**
```powershell
gem install rails
bundle install
```

### **Erro: "ActiveRecord::PendingMigrationError"**

**Causa:** Migrations pendentes

**Solução:**
```powershell
bin/rails db:migrate
```

### **Erro: "TMDB API key missing"**

**Causa:** `TMDB_API_KEY` não configurada

**Solução:**
- Adicione a chave no `.env`
- Reinicie o servidor

### **Assets não carregam (CSS/JS)**

**Causa:** Assets não compilados

**Solução:**
```powershell
# Pré-compilar assets
bin/rails assets:precompile

# Ou limpar cache
bin/rails assets:clobber
bin/rails assets:precompile
```

---

## 🧪 Executando Testes

```powershell
# Executar todos os testes RSpec
bundle exec rspec

# Executar testes específicos
bundle exec rspec spec/models/filme_spec.rb

# Com documentação detalhada
bundle exec rspec --format documentation
```

---

## 🔄 Atualizando o Projeto

```powershell
# Puxar últimas mudanças
git pull origin master

# Atualizar dependências
bundle install
yarn install

# Executar novas migrations
bin/rails db:migrate

# Reiniciar servidor
```

---

## 📚 Próximos Passos

Após configurar o ambiente local:

1. ✅ **Explore a interface:** http://localhost:3000
2. ✅ **Leia FEATURES.md** para ver todas as funcionalidades
3. ✅ **Consulte CSV_IMPORT.md** para importação em massa
4. ✅ **Veja SIDEKIQ.md** para background jobs (opcional)

---

## 💡 Dicas de Desenvolvimento

### **Console Rails Útil:**

```ruby
# Recarregar código sem reiniciar
reload!

# Criar filme de teste
Filme.create!(titulo: "Teste", ano: 2024, categoria: Categoria.first)

# Listar todas as rotas
Rails.application.routes.routes.map(&:path).uniq

# Verificar versão Rails
Rails.version
```

### **Comandos Úteis:**

```powershell
# Verificar status do banco
bin/rails db:version

# Rollback última migration
bin/rails db:rollback

# Resetar banco (CUIDADO: apaga tudo!)
bin/rails db:reset

# Abrir console
bin/rails console

# Ver logs em tempo real
Get-Content log/development.log -Wait
```

---

## 🆘 Precisa de Ajuda?

- 📖 **README.md**: Visão geral do projeto
- 🎯 **FEATURES.md**: Lista de funcionalidades
- 📊 **CSV_IMPORT.md**: Guia de importação
- ⚙️ **SIDEKIQ.md**: Background jobs
- 🐛 **Issues**: Reporte bugs no GitHub

---

**Bom desenvolvimento! 🚀**
