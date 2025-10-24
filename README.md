# 🎬 Cinelog - Sistema de Gestão de Filmes

Aplicação web moderna para gerenciamento de catálogo de filmes construída com Ruby on Rails, featuring autenticação robusta, autorização baseada em papéis, integração com TMDB, sistema de tags, importação CSV em background e notificações por email.

---

## ✨ Funcionalidades Principais

### 🔐 Autenticação e Autorização
- **Sistema de Autenticação Completo** via Devise
  - Registro de usuários com validação de email
  - Login/Logout seguro
  - Recuperação de senha
  - Sistema de sessão persistente (Remember Me)
- **Autorização Baseada em Papéis** via Pundit
  - **Admin**: Controle total do sistema (gerenciar usuários, categorias, filmes, comentários)
  - **Moderador**: Pode moderar comentários e gerenciar filmes
  - **Usuário**: Pode visualizar filmes e adicionar comentários
- Interface em Português com rotas traduzidas (`/login`, `/logout`, `/registrar`)

### 🎥 Gerenciamento de Filmes
- **CRUD Completo** de filmes com interface moderna
  - Criação, edição, visualização e exclusão de filmes
  - Upload de pôsteres com Active Storage
  - Validação de duplicatas (título + ano)
  - Busca em tempo real por título
- **Integração com TMDB (The Movie Database)**
  - Busca automática de informações de filmes
  - Preenchimento automático de dados (sinopse, diretor, ano, gênero)
  - Download automático de pôsteres
  - Armazenamento de TMDB ID para referência
- **Sistema de Tags**
  - Tags many-to-many (um filme pode ter várias tags)
  - Normalização automática (conversão para lowercase)
  - Prevenção de duplicatas
  - Display com badges coloridos na interface
  - Tags editáveis por formulário separado
- **Categorização de Filmes**
  - Associação de filmes a categorias
  - Navegação por categoria
  - Contador de filmes por categoria

### 📂 Gerenciamento de Categorias
- **CRUD Completo** de categorias com interface beautiful
  - Grid responsivo moderno (cards com hover effects)
  - Cores personalizadas por categoria
  - Contador de filmes associados
  - Validação de nome único
  - Proteção contra exclusão de categorias com filmes
- **Interface Moderna**
  - Layout em grid responsivo (1-4 colunas)
  - Efeitos de hover e transições suaves
  - Formulários estilizados com validação em tempo real
  - Confirmação visual para ações destrutivas

### 💬 Sistema de Comentários
- **Comentários Anônimos e Autenticados**
  - Usuários não logados podem comentar (com nome e email)
  - Usuários autenticados comentam automaticamente
  - Display de avatar/ícone e timestamp
- **Moderação de Comentários**
  - Admins e moderadores podem excluir qualquer comentário
  - Usuários podem excluir apenas seus próprios comentários
  - Confirmação obrigatória antes de excluir
  - Proteção via Pundit Policy

### 📊 Importação CSV em Background
- **Sistema Robusto de Importação**
  - Upload de arquivos CSV com filmes em lote
  - Processamento em background via ActiveJob
  - Tracking de status em tempo real (pendente, processando, concluído, falha)
  - Validação de formato e dados
  - Estatísticas detalhadas (total, criados, falhas)
  - Log de erros com detalhes por linha
- **Formato Suportado**:
  ```csv
  titulo,ano,diretor,genero,sinopse,categoria_id,tmdb_id
  ```
- **Integração Automática**
  - Busca automática de informações no TMDB (se tmdb_id fornecido)
  - Criação automática de categorias se não existirem
  - Download automático de pôsteres
  - Prevenção de duplicatas

### 📧 Sistema de Notificações por Email
- **Notificações Automáticas de Importação**
  - Email de sucesso com estatísticas completas
  - Email de falha com detalhes de erro
  - Templates HTML modernos e responsivos
  - Versões plain text para compatibilidade
- **Templates Profissionais**
  - Design com gradientes e ícones
  - Tabelas de estatísticas
  - Botões call-to-action
  - Seção de ajuda e troubleshooting
- **Configuração SMTP**
  - Suporte para Gmail e outros provedores
  - Variáveis de ambiente para segurança
  - Testes incluídos nos seeds

### ⚙️ Background Jobs (Híbrido)
- **Configuração Dual Development/Production**
  - **Development**: `:async` adapter (sem necessidade de Redis)
  - **Production**: `:sidekiq` adapter (com Redis para alta performance)
- **Sidekiq Ready**
  - 3 filas configuradas: `default`, `mailers` (prioridade), `importacoes`
  - Retries automáticos (3x)
  - Web UI para monitoramento (admin only)
  - Logs detalhados com backtrace
- **Flexibilidade**
  - Desenvolva localmente sem Redis
  - Deploy em produção com Sidekiq automaticamente
  - Fácil switch (3 linhas para descomentar)

### 🌐 Interface do Usuário
- **Design Moderno e Responsivo**
  - Header com estilo Tailwind modern (gradientes, sombras)
  - Grid layouts responsivos (CSS Grid)
  - Cards com hover effects e transições
  - Formulários estilizados com validação visual
- **Navegação Intuitiva**
  - Menu principal com links contextuais
  - Breadcrumbs para localização
  - Paginação com Pagy (configurável)
  - Mensagens flash estilizadas
- **Acessibilidade**
  - Semântica HTML5
  - Contraste adequado de cores
  - Suporte a leitores de tela
  - Navegação por teclado

### 🌍 Multilingual
- **Suporte a Português e Inglês**
  - Português (pt-BR) como idioma padrão
  - Traduções completas via i18n
  - Templates de email em Português
  - Mensagens de erro e validação traduzidas

### 📱 Outras Funcionalidades
- **Paginação Eficiente** com Pagy
- **Busca Avançada** por título de filme
- **Upload de Imagens** via Active Storage
- **Seeds com Dados de Teste** (3 usuários + 5 categorias + 10 filmes)
- **Validações Robustas** em todos os models
- **Tratamento de Erros** amigável ao usuário
- **Logs Detalhados** para debugging

---

## 📋 Requisitos do Sistema

### Desenvolvimento
- **Ruby** 3.3.9 ou superior
- **Rails** 7.x ou superior
- **PostgreSQL** 12+
- **Bundler** 2.x
- **Node.js** e **Yarn** (para assets)
- **ImageMagick** ou **libvips** (para processamento de imagens)

### Produção (Adicional)
- **Redis** 4+ (para Sidekiq background jobs)
- **Servidor Web** (Puma incluído)
- **SSL Certificate** (recomendado)

---

## 🚀 Configuração do Projeto

### **1. Clone o Repositório**

```powershell
git clone <seu-repositorio>
cd Cinelog
```

### **2. Instale as Dependências**

```powershell
# Instalar gems Ruby
bundle install

# Instalar dependências JavaScript
yarn install
# ou: npm install
```

### **3. Configure o Banco de Dados**

Edite `config/database.yml` ou defina variável de ambiente:

```powershell
# Opção 1: Editar config/database.yml
# Ajuste username e password do PostgreSQL

# Opção 2: Usar variável de ambiente
$env:DATABASE_URL="postgresql://usuario:senha@localhost:5432/cinelog_development"
```

### **4. Configure Variáveis de Ambiente**

Crie arquivo `.env` na raiz do projeto:

```env
# Banco de Dados
DATABASE_URL=postgresql://usuario:senha@localhost:5432/cinelog_development

# TMDB API (obtenha em https://www.themoviedb.org/settings/api)
TMDB_API_KEY=sua_chave_api_aqui

# SMTP Gmail (para notificações de importação)
GMAIL_USERNAME=seu.email@gmail.com
GMAIL_PASSWORD=sua_senha_de_app_aqui

# Redis (apenas para produção com Sidekiq)
# REDIS_URL=redis://localhost:6379/1
```

**Importante**: Adicione `.env` ao `.gitignore` para não expor credenciais!

### **5. Prepare o Banco de Dados**

```powershell
# Criar banco de dados
bin/rails db:create

# Executar migrations
bin/rails db:migrate

# Popular com dados iniciais (usuários, categorias, filmes)
bin/rails db:seed
```

### **6. Inicie o Servidor**

```powershell
# Iniciar servidor Rails
bin/rails server

# Ou com bundle exec
bundle exec rails server
```

Acesse: **http://localhost:3000**

---

## 🔑 Credenciais de Desenvolvimento

Após executar `rails db:seed`, você terá os seguintes usuários de teste:

| Papel | Email | Senha | Descrição |
|-------|-------|-------|-----------|
| **Admin** | `admin@cinelog.com` | `admin123` | Acesso total ao sistema |
| **Moderador** | `moderador@cinelog.com` | `moderador123` | Pode moderar comentários |
| **Usuário** | `usuario@cinelog.com` | `usuario123` | Acesso básico |

### Dados de Seed Criados:
- **3 usuários** (admin, moderador, usuário)
- **5 categorias** (Ação, Comédia, Drama, Ficção Científica, Terror)
- **10 filmes** com pôsteres, tags e informações completas
- **Comentários de exemplo**

---

## 📦 Estrutura do Projeto

```
Cinelog/
├── app/
│   ├── controllers/          # Controladores MVC
│   │   ├── filmes_controller.rb
│   │   ├── categorias_controller.rb
│   │   ├── comentarios_controller.rb
│   │   ├── importacoes_controller.rb
│   │   └── usuarios/
│   ├── models/               # Modelos de dados
│   │   ├── filme.rb
│   │   ├── categoria.rb
│   │   ├── tag.rb
│   │   ├── comentario.rb
│   │   ├── usuario.rb
│   │   └── importacao.rb
│   ├── views/                # Templates ERB
│   │   ├── filmes/
│   │   ├── categorias/
│   │   ├── importacoes/
│   │   ├── layouts/
│   │   └── importacao_mailer/  # Templates de email
│   ├── jobs/                 # Background jobs
│   │   └── importacao_job.rb
│   ├── mailers/              # Email mailers
│   │   └── importacao_mailer.rb
│   ├── policies/             # Pundit authorization
│   │   ├── filme_policy.rb
│   │   └── comentario_policy.rb
│   └── services/             # Serviços externos
│       └── servico_tmdb.rb
├── config/
│   ├── application.rb
│   ├── database.yml
│   ├── routes.rb
│   ├── sidekiq.yml           # Configuração Sidekiq
│   └── initializers/
│       ├── devise.rb
│       ├── pagy.rb
│       └── sidekiq.rb
├── db/
│   ├── migrate/              # Migrations
│   ├── schema.rb
│   └── seeds.rb              # Dados iniciais
├── public/                   # Assets públicos
├── storage/                  # Arquivos uploaded (pôsteres, CSVs)
├── Gemfile                   # Dependências Ruby
├── Procfile                  # Processos para deployment
└── README.md                 # Este arquivo
```

---

## 🔧 Configurações Importantes

### **TMDB API** 
Para busca automática de filmes:

1. Crie conta em https://www.themoviedb.org/
2. Vá em Settings → API
3. Solicite API Key (gratuita)
4. Defina `TMDB_API_KEY` no `.env`

### **SMTP Gmail**
Para notificações de importação:

1. Habilite autenticação de 2 fatores no Gmail
2. Gere senha de app em https://myaccount.google.com/apppasswords
3. Defina `GMAIL_USERNAME` e `GMAIL_PASSWORD` no `.env`

**Nota**: Para outros provedores, ajuste `config/environments/production.rb`

### **Background Jobs (Development vs Production)**

#### **Development (Local sem Redis):**
- Usa `:async` adapter (in-memory)
- Não requer Redis instalado
- Perfeito para testes locais
- Configurado em `config/environments/development.rb`

#### **Production (Com Sidekiq + Redis):**
- Usa `:sidekiq` adapter
- Requer Redis 4+
- Alta performance e confiabilidade
- Web UI para monitoramento
- Para ativar localmente:
  1. Instale Redis 4+
  2. Descomente linha em `config/routes.rb`
  3. Comente override em `config/environments/development.rb`
  4. Inicie Redis e Sidekiq:
     ```powershell
     redis-server
     bundle exec sidekiq -C config/sidekiq.yml
     ```
  5. Acesse dashboard: http://localhost:3000/sidekiq

---

## 📤 Importação CSV

### **Formato do Arquivo**

```csv
titulo,ano,diretor,genero,sinopse,categoria_id,tmdb_id
Matrix,1999,Lana Wachowski,Ficção Científica,Um hacker descobre a verdade...,4,603
Vingadores Ultimato,2019,Russo Brothers,Ação,Os heróis remanescentes...,1,299534
```

### **Campos:**
- `titulo` (obrigatório): Nome do filme
- `ano` (obrigatório): Ano de lançamento
- `diretor` (opcional): Nome do diretor
- `genero` (opcional): Gênero do filme
- `sinopse` (opcional): Descrição
- `categoria_id` (opcional): ID da categoria existente
- `tmdb_id` (opcional): Se fornecido, busca dados automaticamente no TMDB

### **Como Usar:**
1. Faça login como usuário autenticado
2. Vá em "Importar Filmes" no menu
3. Selecione arquivo CSV
4. Aguarde processamento em background
5. Receba email com resultado (sucesso/falha)

### **Validações:**
- ✅ Formato CSV válido
- ✅ Campos obrigatórios preenchidos
- ✅ Prevenção de duplicatas (título + ano)
- ✅ Log detalhado de erros por linha

---

## 🚀 Deploy para Produção

### **Requisitos de Produção:**
- PostgreSQL database (managed ou self-hosted)
- Redis 4+ (para Sidekiq)
- Variáveis de ambiente configuradas
- SSL certificate (Let's Encrypt recomendado)
- Domínio próprio (opcional)

### **Procfile Incluído:**
```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
```

---

## 🧪 Testes

```powershell
# Executar testes RSpec
bundle exec rspec

# Com coverage
bundle exec rspec --format documentation
```

---

## 🛠️ Troubleshooting

### **Erro: "could not connect to server"**
- Verifique se PostgreSQL está rodando
- Confirme credenciais em `database.yml` ou `DATABASE_URL`

### **Erro: "TMDB API key missing"**
- Defina `TMDB_API_KEY` no `.env`
- Reinicie o servidor Rails

### **Emails não estão sendo enviados**
- Verifique `GMAIL_USERNAME` e `GMAIL_PASSWORD` no `.env`
- Confirme que gerou senha de app (não senha normal do Gmail)
- Em development, emails aparecem no log (não são enviados de verdade)

### **Importação CSV não funciona**
- Verifique formato do arquivo (encoding UTF-8)
- Confirme que headers estão corretos
- Veja logs detalhados na página de status da importação
- Verifique email para detalhes do erro

### **Sidekiq não inicia**
- Certifique-se que Redis está rodando: `redis-cli ping` (deve retornar `PONG`)
- Se não tiver Redis, use modo `:async` (development padrão)
- Verifique `REDIS_URL` em produção

---

## 📚 Documentação Adicional

- **`DEPLOY_DIGITALOCEAN.md`** - Guia completo de deployment (3 opções)
- **`SIDEKIQ_SETUP.md`** - Configuração detalhada do Sidekiq
- **`QUICK_START_SIDEKIQ.md`** - Início rápido com Sidekiq (3 passos)
- **`IMPORTACAO_CSV.md`** - Detalhes sobre importação de filmes

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:
- Reportar bugs via issues
- Sugerir novas funcionalidades
- Enviar pull requests
- Melhorar documentação

---

## 📄 Licença

Este projeto é de código aberto. Sinta-se livre para usar e modificar conforme necessário.

---

## 👨‍💻 Tecnologias Utilizadas

- **Backend**: Ruby on Rails 7.x
- **Database**: PostgreSQL 12+
- **Authentication**: Devise
- **Authorization**: Pundit
- **Background Jobs**: ActiveJob + Sidekiq (produção)
- **Email**: ActionMailer + SMTP
- **File Upload**: Active Storage
- **Pagination**: Pagy
- **HTTP Client**: Faraday (para TMDB API)
- **Testing**: RSpec (configurado)
- **CSS**: Custom CSS com inspiração Tailwind
- **JavaScript**: Stimulus (Rails default)
- **Deploy**: Pronto para Heroku, DigitalOcean, Render, etc.

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique a seção **Troubleshooting** acima
2. Consulte os arquivos de documentação na raiz do projeto
3. Abra uma issue no repositório

---

**Desenvolvido com ❤️ usando Ruby on Rails**
