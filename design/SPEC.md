# SPEC - Projeto Cinelog

Versão: 0.1
Data: 2025-10-21

Resumo
------
Aplicação web "cinelog" — catálogo de filmes em Ruby on Rails + PostgreSQL.
Objetivos principais: organização do código seguindo Clean Code, código em português, orientação a objetos e arquitetura MVC clara. Integração do design local presente em `design/templatemo_579_cyborg_gaming` adaptado para tema branco/verde.

1. Requisitos funcionais principais
---------------------------------
- Área pública (sem login)
  - Listagem de todos os filmes cadastrados, paginada (6 por página), ordenada do mais novo para o mais antigo.
  - Página de detalhes do filme: exibir título, sinopse, ano de lançamento, duração (em minutos) e diretor.
  - Possibilidade de adicionar comentários anônimos (fornecendo apenas nome e conteúdo).
  - Comentários ordenados do mais recente para o mais antigo.
  - Cadastro de novo usuário e recuperação de senha.

- Área autenticada (com login)
  - Logout.
  - Usuário autenticado pode cadastrar, editar e apagar filmes.
  - Apenas o usuário que criou o filme pode editá-lo/apagá-lo ou então um administrador pode apaga-lo.
  - Usuário autenticado comenta automaticamente com seu nome vinculado.
  - Editar perfil e alterar senha.

2. Funcionalidades opcionais (priorizadas)
-------------------------------------------
- Categorias (m:n) e filtros por categoria.
- Busca por título, diretor e/ou ano (full-text/pg_search).
- Upload de poster do filme via Active Storage.
- Importação em massa via CSV (processamento em background com ActiveJob/Sidekiq) com rastreamento de status e envio de email ao término.
- Integração com TMDB para preencher automaticamente sinopse/ano/duração/diretor ao digitar o título no formulário.
- Internacionalização (pt-BR e en).
- Testes automatizados básicos (RSpec) e lint (RuboCop).

2.1 Papéis e permissões (RBAC)
--------------------------------
É recomendado adicionar um sistema simples de papéis para controlar permissões globais e administrativas. A abordagem recomendada é um campo `papel` no modelo `Usuario` com valores enumerados: `usuario`, `moderador`, `admin`.

Sugestão de papéis e responsabilidades:
- admin: gerencia tudo (criar/editar/apagar qualquer filme, gerenciar usuários, categorias e apagar comentários).
- moderador: gerencia conteúdos (apaga comentários problemáticos, revisa importações, edita categorias).
- usuario: ações normais (criar/editar/apagar apenas seus próprios filmes, comentar, editar perfil).

Implementação prática:
- Migration: `add_column :usuarios, :papel, :string, null: false, default: 'usuario'`.
- Modelo: usar enum em `Usuario`:
  ```ruby
  class Usuario < ApplicationRecord
    enum papel: { usuario: 'usuario', moderador: 'moderador', admin: 'admin' }
  end
  ```
- Políticas Pundit: adaptar `FilmePolicy`, `ComentarioPolicy` e outros para permitir que `admin` e `moderador` tenham permissões ampliadas quando apropriado.

Critérios de aceitação:
- Usuário com `papel: 'admin'` consegue executar ações administrativas conforme definido.
- Usuário `moderador` pode gerenciar comentários e revisar importações.
- Usuário padrão (`usuario`) tem apenas permissões sobre seus próprios recursos.


3. Stack e dependências recomendadas
-----------------------------------
- Ruby 3.1+ (recomendado 3.2)
- Rails 7.x
- Banco: PostgreSQL
- Gems essenciais sugeridas:
  - devise (autenticação)
  - pundit (autorização)
  - pagy (paginação)
  - active_storage (já embutido)
  - pg_search (busca)
  - httparty ou faraday (integração TMDB)
  - sidekiq + redis (import CSV background — opcional em produção)
  - rspec-rails, factory_bot_rails (testes)
  - rubocop (lint)

4. Modelagem (resumo de atributos)
---------------------------------

Usuario (Usuario - Devise)
- atributos importantes: nome:string, email:string, encrypted_password, etc.

Filme
- titulo:string (index)
- sinopse:text
- ano_lancamento:integer
- duracao_minutos:integer
- diretor:string
- user:references (autor)
- timestamps
- Attachment: poster (Active Storage)

Comentario
- conteudo:text
- nome_autor:string (quando anônimo)
- user:references (opcional)
- filme:references
- timestamps

Categoria (opcional)
- nome:string
- relacionamento m:n com filmes via filmes_categorias

Importacao (opcional)
- arquivo (Active Storage)
- status:string (pendente, em_andamento, concluido, erro)
- total:integer, processados:integer, erros:text/json

5. Rotas (routes.rb) - mapeamento principal
------------------------------------------
- root "filmes#index"
- resources :filmes do
  - resources :comentarios, only: [:create, :destroy]
  - collection: get :buscar (ou rota separada `get '/buscar' => 'filmes#buscar'`)
end
- devise_for :usuarios, controllers: { registrations: 'usuarios/registrations' }
- post '/tmdb_lookup' => 'servicos#tmdb_lookup'
- resources :importacoes, only: [:new, :create, :show]

6. Contratos (API / Formatos)
-----------------------------

CSV de importação (exemplo de header obrigatório):
"titulo","sinopse","ano_lancamento","duracao_minutos","diretor","categorias"
- categorias: lista separada por `;` (opcional)

Regras de validação na importação:
- linhas com erro devem ser registradas com a mensagem e número da linha.
- filmes duplicados (mesmo título + ano) devem ser ignorados ou atualizados dependendo do parâmetro `modo=criar|atualizar`.

Resposta do endpoint TMDB (`/tmdb_lookup`) - JSON esperado (simplificado):
{
  "sinopse": "...",
  "ano_lancamento": 2020,
  "duracao_minutos": 120,
  "diretor": "Nome do Diretor",
  "erro": null
}

7. Variáveis de ambiente necessárias
-----------------------------------
- DATABASE_URL ou config separada em `config/database.yml` para cada ambiente
- RAILS_ENV
- SECRET_KEY_BASE
- TMDB_API_KEY (chave pública da API TMDB)
- SMTP_* (MAILER_ADDRESS, MAILER_PORT, MAILER_USER, MAILER_PASS) para envio de e-mails de recuperação de senha e importação
- AWS_S3_* (se usar S3 para Active Storage em produção)

8. Critérios de aceitação (exemplos)
----------------------------------
- Listagem pública: ao acessar `/` o usuário vê até 6 filmes por página, primeiro os mais recentes.
- Detalhes: `/filmes/:id` exibe título, sinopse, ano, duração e diretor corretamente.
- Comentário anônimo: formulário de comentário sem login cria registro com `nome_autor` e exibe no detalhe do filme.
- CRUD autorizado: só o autor (campo user_id) consegue acessar `edit`, `update` e `destroy` do filme.
- Recuperação de senha: fluxo Devise funcionando via e-mail (em dev usar letter_opener/local). 

9. Integração do design e tema branco/verde
------------------------------------------
- Base: copiar os arquivos de `design/templatemo_579_cyborg_gaming` para `app/views/layouts` e `app/assets` conforme organização Rails.
- CSS: criar um arquivo `_tema.scss` com variáveis CSS no topo e substituir cores do template original por:
  - cor-primaria: #0b6f3a (verde)
  - cor-bg: #ffffff (branco)
  - cor-secundaria/texto: #0b3f2a ou similar para contraste
- Assets JS e imagens: migrar `assets/js` para `app/javascript` (jsbundling) ou `app/assets/javascripts` dependendo da configuração do projeto.
- Logo: atualizar para mostrar "cinelog"; revisar header/footer para navegação (login, cadastrar, filtrar, buscar).

10. Qualidade do código
-----------------------
- Nomes em português (modelos/atributos/metodos) com snake_case (ex: `duracao_minutos`).
- Classes e módulos em PascalCase (ex: `Filme`, `ServicoTmdb`).
- Controllers finos: delegar regras de negócio para models e services.
- Service objects para TMDB e import CSV. Jobs para processamento em background.
- RuboCop com regras básicas; comentários explicativos que justifiquem decisões importantes.

11. Testes e CI (mínimo)
-----------------------
- RSpec: testes de modelo (validações), controller (index/show), e fluxo de autenticação básica.
- RuboCop: lint básico antes de commitar.

12. Deploy (Render) - notas rápidas
----------------------------------
- Usar Postgres gerenciado pela Render.
- Variáveis de ambiente para keys e SMTP configuradas via painel do Render.
- Active Storage: preferir S3 em produção; configurar `config/storage.yml`.
- Se Sidekiq for necessário, documentar que Render exige plano que suporte workers; caso contrário, usar ActiveJob com alternativa.

13. Cronograma sugerido (alto nível)
----------------------------------
1. Especificação e esqueleto (1-2 dias)
2. Autenticação e modelagem (1-2 dias)
3. CRUD de filmes e comentários (2-3 dias)
4. Integração do design e ajustes, upload (2 dias)
5. CSV import, TMDB e testes (2-4 dias)
6. Deploy e ajustes finais (1-2 dias)

14. Observações finais
---------------------
- Manter compatibilidade com acessibilidade e responsividade.
- Registrar todas as decisões importantes no `SPEC.md` e `README.md` durante o desenvolvimento.
- Não versionar chaves sensíveis; usar `credentials`/env vars.

--
Especificação gerada por: plano inicial automatizado. Próximo passo: gerar o esqueleto Rails e configurar Devise + Postgres.
