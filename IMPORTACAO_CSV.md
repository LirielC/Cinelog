# Importação CSV - Documentação

## Visão Geral

A funcionalidade de Importação CSV permite que usuários autenticados façam upload de um arquivo CSV para criar múltiplos filmes de uma vez. O processamento é **assíncrono usando Sidekiq** (background job com Redis), e o sistema fornece feedback detalhado sobre o resultado da importação, incluindo **notificação por e-mail**.

## ⚙️ Requisitos

- **Redis**: Servidor Redis rodando (necessário para Sidekiq)
- **Sidekiq**: Worker rodando para processar jobs
- **SMTP**: Configurado para envio de e-mails

### Iniciar Serviços

```bash
# 1. Iniciar Redis
redis-server

# 2. Iniciar Rails
rails server

# 3. Iniciar Sidekiq (em outro terminal)
.\bin\sidekiq.cmd
# ou
bundle exec sidekiq -C config/sidekiq.yml
```

📖 **Ver documentação completa**: `SIDEKIQ_SETUP.md`

## Arquitetura

### Componentes Implementados

1. **Modelo: `Importacao`** (`app/models/importacao.rb`)
   - Rastreia o status de cada importação
   - Estados: `pendente`, `processando`, `concluido`, `falha`
   - Associado ao usuário que fez o upload
   - Armazena estatísticas: total_linhas, criados, falhas, erros

2. **Job: `ImportacaoJob`** (`app/jobs/importacao_job.rb`)
   - Processa o CSV em background **via Sidekiq**
   - Fila: `importacoes`
   - Valida cabeçalhos do arquivo
   - Cria filmes linha por linha
   - Tratamento robusto de erros
   - Limpa arquivo temporário após processamento
   - **Envia e-mail de notificação ao finalizar**

3. **Mailer: `ImportacaoMailer`** (`app/mailers/importacao_mailer.rb`)
   - `importacao_concluida`: E-mail com resumo de sucesso
   - `importacao_falhou`: E-mail com detalhes do erro
   - Processado na fila `mailers` do Sidekiq

3. **Controller: `ImportacoesController`** (`app/controllers/importacoes_controller.rb`)
   - `new`: Formulário de upload
   - `create`: Valida arquivo e enfileira job
   - `show`: Exibe status e resultado da importação

4. **Views:**
   - `new.html.erb`: Formulário com instruções detalhadas do formato CSV
   - `show.html.erb`: Dashboard com estatísticas e log de erros

5. **Testes: `spec/jobs/importacao_job_spec.rb`**
   - 17 testes cobrindo casos de sucesso e erro
   - Validação de cabeçalhos, linhas inválidas, arquivos malformados, etc.

## Formato CSV

### Cabeçalhos Obrigatórios

```
titulo,sinopse,ano_lancamento,duracao_minutos,diretor,categorias
```

### Regras

1. **Título**: Obrigatório. String não vazia
2. **Sinopse**: Opcional. String
3. **Ano de Lançamento**: Opcional. Número inteiro (ex: 2020)
4. **Duração em Minutos**: Opcional. Número inteiro (ex: 120)
5. **Diretor**: Opcional. String
6. **Categorias**: Opcional. String com categorias separadas por vírgula
   - Use aspas se tiver vírgula: `"Ação,Drama"`
   - Categorias serão criadas automaticamente se não existirem

### Exemplo de CSV Válido

```csv
titulo,sinopse,ano_lancamento,duracao_minutos,diretor,categorias
Matrix,Um hacker descobre a realidade,1999,136,Lana Wachowski,"Ação,Ficção Científica"
Interestelar,Exploradores atravessam um buraco de minhoca,2014,169,Christopher Nolan,"Ficção Científica,Drama"
O Poderoso Chefão,A saga de uma família mafiosa,1972,175,Francis Ford Coppola,"Drama,Crime"
```

## Validações

### No Controller

- **Tipo de arquivo**: Apenas `.csv`, `text/csv`, `application/vnd.ms-excel`, `text/plain`
- **Tamanho máximo**: 5 MB
- **Arquivo presente**: Rejeita se nenhum arquivo foi selecionado

### No Job

- **Cabeçalhos**: Verifica se todas as colunas esperadas estão presentes
- **Tamanho do arquivo**: Valida limite de 5MB antes de processar
- **Existência**: Verifica se arquivo existe antes de processar
- **Título**: Obrigatório por filme (linhas sem título são ignoradas)

## Fluxo de Processamento

1. **Upload** (Controller):
   - Usuário seleciona arquivo CSV
   - Controller valida tipo e tamanho
   - Arquivo é salvo em `tmp/importacao_#{timestamp}_#{filename}.csv`
   - Registro `Importacao` criado com status `pendente`
   - Job enfileirado: `ImportacaoJob.perform_later(importacao.id)`
   - Usuário redirecionado para página de status

2. **Processamento** (Job):
   - Job atualiza status para `processando`
   - Valida existência e tamanho do arquivo
   - Valida cabeçalhos do CSV
   - Para cada linha:
     - Cria ou reutiliza categorias (via `find_or_create_by`)
     - Cria filme associado ao usuário
     - Registra sucesso ou erro
   - Atualiza importação com estatísticas finais
   - Remove arquivo temporário

3. **Resultado** (View):
   - Dashboard mostra:
     - Status da importação
     - Quantidade de filmes criados
     - Quantidade de falhas
     - Taxa de sucesso (%)
     - Log detalhado de erros (se houver)

4. **Notificação por E-mail** (Mailer):
   - **Sucesso**: E-mail HTML bonito com estatísticas e resumo
   - **Falha**: E-mail com detalhes do erro e dicas de resolução
   - Enviado automaticamente via Sidekiq (fila `mailers`)

## Tratamento de Erros

### Erros por Linha

- Linha sem título → Ignorada, erro registrado
- Validação do modelo falha → Ignorada, mensagem de erro registrada
- Exceção inesperada → Capturada, erro registrado

### Erros Globais

- Arquivo não encontrado → Status `falha`, importação abortada
- Arquivo muito grande → Status `falha`, importação abortada
- Cabeçalhos inválidos → Status `falha`, nenhum filme criado
- CSV malformado → Status `falha`, erro capturado

### Estratégia

- **Erros parciais**: Importação marcada como `concluido` com estatísticas de falhas
- **Erros críticos**: Importação marcada como `falha`, processamento abortado
- **Todos os erros são logados** no campo `erros` da importação

## Testes

### Cobertura (17 specs)

1. **CSV válido**: Cria filmes, atualiza status, registra estatísticas
2. **Linhas inválidas**: Processa válidas, pula inválidas, registra erros
3. **Cabeçalhos inválidos**: Aborta sem criar filmes
4. **Arquivo inexistente**: Marca como falha
5. **CSV malformado**: Captura erro, marca como falha
6. **Erros inesperados**: Captura e registra
7. **Integração**: Associa usuário, cria/reutiliza categorias

### Como Executar

```bash
bundle exec rspec spec/jobs/importacao_job_spec.rb --format documentation
```

## Acesso

### Via Interface Web

1. Login necessário
2. Clique em "Importar CSV" no menu superior
3. Selecione arquivo CSV
4. Aguarde processamento (página de status com botão recarregar)

### Via Console Rails

```ruby
# Criar importação manualmente
usuario = Usuario.first
importacao = Importacao.create!(
  usuario: usuario,
  arquivo: '/caminho/para/arquivo.csv',
  status: 'pendente'
)

# Processar sincronamente (útil para debugging)
ImportacaoJob.perform_now(importacao.id)

# Processar assincronamente (produção)
ImportacaoJob.perform_later(importacao.id)
```

## Segurança

- **Autenticação**: Apenas usuários logados podem importar
- **Autorização**: Usuário só vê suas próprias importações (ou admin vê todas)
- **Validação de arquivo**: Tipo, tamanho e conteúdo validados
- **Limpeza**: Arquivos temporários removidos após processamento
- **Limite de tamanho**: 5MB máximo para prevenir sobrecarga

## Performance

- **Processamento assíncrono**: Não bloqueia a request HTTP
- **Batch processing**: CSV processado linha por linha (memória eficiente)
- **Categorias**: `find_or_create_by` previne duplicação, mas não há transação por lote
  - Consideração futura: usar `upsert_all` para importações muito grandes

## Melhorias Futuras (TODOs)

1. **Validação de preview**: Mostrar primeiras 5 linhas antes de confirmar
2. **Progress bar**: Usar Action Cable para atualização em tempo real
3. **Download de relatório**: Exportar log de erros como CSV
4. **Re-tentar falhas**: Permitir reprocessar apenas linhas com erro
5. **Atualização de filmes existentes**: Opção para update ao invés de apenas insert
6. **Validação avançada**: Checar duplicatas de título antes de inserir
7. **Limpar importações antigas**: Job periódico para remover registros antigos

## Exemplo de Uso Real

```bash
# 1. Prepare o CSV
cat > filmes.csv << 'EOF'
titulo,sinopse,ano_lancamento,duracao_minutos,diretor,categorias
Matrix,Um hacker descobre a realidade,1999,136,Lana Wachowski,"Ação,Ficção Científica"
Interestelar,Exploradores atravessam,2014,169,Christopher Nolan,"Ficção Científica,Drama"
EOF

# 2. Acesse a aplicação
# http://localhost:3000/importacoes/new

# 3. Faça upload do arquivo

# 4. Aguarde processamento
# http://localhost:3000/importacoes/1

# 5. Verifique filmes criados
# http://localhost:3000/filmes
```

## Logs e Debugging

### Logs do Rails

```bash
# Development
tail -f log/development.log | grep Importacao

# Ver informações de uma importação específica
rails console
> importacao = Importacao.find(1)
> puts importacao.erros
> puts "Criados: #{importacao.criados}/#{importacao.total_linhas}"
```

### Verificar Job Queue

```ruby
# Ver jobs pendentes
ActiveJob::Base.queue_adapter

# Se usando Sidekiq:
Sidekiq::Queue.all.each { |q| puts "#{q.name}: #{q.size}" }
```

## Referências

- Modelo: `app/models/importacao.rb`
- Job: `app/jobs/importacao_job.rb`
- Controller: `app/controllers/importacoes_controller.rb`
- Routes: `resources :importacoes, only: [:new, :create, :show]`
- Migration: `db/migrate/20251022001044_create_importacaos.rb`
- Testes: `spec/jobs/importacao_job_spec.rb`
- CSV exemplo: `tmp/filmes_exemplo.csv`
