# 📁 Importação CSV - Formato e Guia

Documentação completa sobre importação em massa de filmes via CSV no Cinelog.

---

## 📋 Visão Geral

O sistema de importação permite adicionar múltiplos filmes de uma vez usando arquivos CSV. Os dados são enriquecidos automaticamente com informações do TMDB (The Movie Database).

### **Características:**

- ✅ Processamento em background (via ActiveJob)
- ✅ Validações completas
- ✅ Busca automática de dados no TMDB
- ✅ Download de posters
- ✅ Notificação por email ao finalizar
- ✅ Rastreamento de progresso (sucesso/falha por linha)
- ✅ Relatório detalhado de erros

---

## 📄 Formato do Arquivo CSV

### **Estrutura Básica:**

```csv
titulo,ano,diretor,genero,sinopse,categoria_id,tmdb_id
Matrix,1999,Lana Wachowski,Ficção Científica,Um hacker descobre a verdade,1,603
Inception,2010,Christopher Nolan,Thriller,Um ladrão invade sonhos,1,27205
Parasite,2019,Bong Joon-ho,Drama,Uma família se infiltra,2,496243
```

### **Campos Obrigatórios:**

| Campo | Tipo | Obrigatório | Descrição | Exemplo |
|-------|------|-------------|-----------|---------|
| `titulo` | String | ✅ **SIM** | Nome do filme | `Matrix` |
| `ano` | Integer | ✅ **SIM** | Ano de lançamento | `1999` |
| `diretor` | String | ✅ **SIM** | Nome do diretor | `Lana Wachowski` |
| `genero` | String | ❌ Não | Gênero do filme | `Ficção Científica` |
| `sinopse` | Text | ❌ Não | Descrição do filme | `Um hacker descobre...` |
| `categoria_id` | Integer | ✅ **SIM** | ID da categoria existente | `1` |
| `tmdb_id` | Integer | ❌ Não | ID no TMDB (recomendado) | `603` |

---

## 🔍 Integração com TMDB

### **Funcionamento:**

1. **Com `tmdb_id` informado:**
   - Sistema busca dados completos no TMDB
   - Preenche automaticamente: sinopse, gênero, poster
   - Dados do CSV são usados como fallback

2. **Sem `tmdb_id`:**
   - Sistema tenta buscar filme por título + ano
   - Se encontrar, preenche dados automaticamente
   - Se não encontrar, usa apenas dados do CSV

### **Campos Preenchidos Automaticamente:**

- 📝 **Sinopse** (traduzida para PT-BR)
- 🎭 **Gênero** (lista de gêneros do TMDB)
- 🖼️ **Poster** (download automático via Active Storage)
- 🎬 **Dados adicionais** (popularidade, avaliação, etc.)

### **Encontrar tmdb_id:**

1. Acesse: https://www.themoviedb.org/
2. Busque pelo filme
3. Veja a URL: `https://www.themoviedb.org/movie/603-the-matrix`
4. O número após `/movie/` é o **tmdb_id** (603)

---

## 📋 Categorias Disponíveis

Antes de importar, verifique os IDs de categoria disponíveis:

### **Console Rails:**

```ruby
rails console

# Listar todas categorias
Categoria.all.pluck(:id, :nome)
# => [[1, "Ação"], [2, "Drama"], [3, "Comédia"], ...]
```

### **Seeds Padrão:**

Se usar `rails db:seed`, as categorias criadas são:

| ID | Nome | Descrição |
|----|------|-----------|
| 1 | Ação | Filmes de ação e aventura |
| 2 | Drama | Dramas e histórias emocionantes |
| 3 | Comédia | Filmes cômicos |
| 4 | Terror | Filmes de horror |
| 5 | Ficção Científica | Sci-fi e futurismo |

---

## 📥 Exemplos de CSV

### **Exemplo 1: CSV Mínimo (Sem TMDB)**

```csv
titulo,ano,diretor,genero,sinopse,categoria_id,tmdb_id
Filme Teste,2024,Diretor Teste,Drama,Uma história interessante,2,
```

**Resultado:**
- ✅ Filme criado com dados manuais
- ❌ Sem poster
- ❌ Sem busca TMDB

### **Exemplo 2: CSV Completo (Com TMDB)**

```csv
titulo,ano,diretor,genero,sinopse,categoria_id,tmdb_id
Matrix,1999,Lana Wachowski,Ficção Científica,Um hacker descobre a verdade sobre a realidade,1,603
Inception,2010,Christopher Nolan,Thriller,Um ladrão invade sonhos para roubar segredos,1,27205
Parasite,2019,Bong Joon-ho,Drama,Uma família pobre se infiltra em uma família rica,2,496243
Interstellar,2014,Christopher Nolan,Ficção Científica,Astronautas buscam novo lar para humanidade,5,157336
The Dark Knight,2008,Christopher Nolan,Ação,Batman enfrenta o Coringa,1,155
Pulp Fiction,1994,Quentin Tarantino,Crime,Histórias entrelaçadas do submundo,2,680
Fight Club,1999,David Fincher,Drama,Um homem insone cria clube secreto,2,550
```

**Resultado:**
- ✅ Filmes criados com dados do TMDB
- ✅ Posters baixados automaticamente
- ✅ Sinopses completas em PT-BR
- ✅ Gêneros atualizados

### **Exemplo 3: CSV com Erros (Para Testar Validação)**

```csv
titulo,ano,diretor,genero,sinopse,categoria_id,tmdb_id
,1999,Diretor Sem Titulo,,Sinopse sem titulo,1,
Filme Sem Ano,,Diretor Teste,,Sem ano definido,1,
Filme Sem Diretor,2020,,,Sem diretor definido,1,
Filme Categoria Invalida,2020,Diretor Teste,,Categoria inexistente,999,
```

**Resultado:**
- ❌ 4 filmes com erros
- ✅ Relatório detalhado de erros
- ✅ Email com linhas que falharam

---

## 🚀 Como Importar

### **1. Via Interface Web**

#### **a) Acesse a página de importação:**

```
http://localhost:3000/importacoes/new
```

#### **b) Faça upload do CSV:**

- Clique em "Escolher arquivo"
- Selecione seu arquivo `.csv`
- Clique em "Iniciar Importação"

#### **c) Acompanhe o progresso:**

- Você será redirecionado para a lista de importações
- Status disponíveis:
  - 🟡 **Pendente**: Na fila de processamento
  - 🔵 **Processando**: Sendo executada agora
  - 🟢 **Concluída**: Finalizada com sucesso
  - 🔴 **Erro**: Falhou durante processamento

#### **d) Veja resultados:**

- Clique em "Ver Detalhes"
- Veja quantos filmes foram:
  - ✅ Importados com sucesso
  - ❌ Falharam
- Baixe relatório de erros (se houver)

### **2. Via Console Rails**

```ruby
rails console

# Criar importação manualmente
importacao = Importacao.create!(
  usuario_id: 1,
  arquivo: File.open('tmp/filmes.csv')
)

# Processar imediatamente (síncrono)
ImportacaoJob.perform_now(importacao.id)

# Ou enfileirar (assíncrono)
ImportacaoJob.perform_later(importacao.id)
```

---

## ⚙️ Processo de Importação

### **Fluxo Completo:**

```
1. Upload do CSV
   ↓
2. Validação inicial (formato, campos obrigatórios)
   ↓
3. Job enfileirado (ActiveJob)
   ↓
4. Processamento em background (ImportacaoJob)
   ├─ Para cada linha:
   │  ├─ Validar dados
   │  ├─ Buscar no TMDB (se tmdb_id)
   │  ├─ Criar filme
   │  ├─ Baixar poster
   │  └─ Registrar sucesso/erro
   ↓
5. Email de notificação enviado
   ├─ Resumo: X sucessos, Y falhas
   └─ Relatório de erros anexado
   ↓
6. Status atualizado para "Concluída"
```

### **Código Interno (Simplificado):**

```ruby
# app/jobs/importacao_job.rb
class ImportacaoJob < ApplicationJob
  queue_as :importacoes

  def perform(importacao_id)
    importacao = Importacao.find(importacao_id)
    importacao.update(status: 'processando')

    resultados = processar_csv(importacao.arquivo)

    importacao.update(
      status: 'concluida',
      total_linhas: resultados[:total],
      linhas_sucesso: resultados[:sucesso],
      linhas_erro: resultados[:erro],
      mensagens_erro: resultados[:erros]
    )

    # Enviar email
    ImportacaoMailer.notificacao(importacao).deliver_later
  end

  private

  def processar_csv(arquivo)
    # ... lógica de processamento ...
  end
end
```

---

## 📊 Validações

### **Validações de Formato:**

| Validação | Regra | Exemplo Válido | Exemplo Inválido |
|-----------|-------|----------------|------------------|
| Título | Presente, String | `Matrix` | ` ` (vazio) |
| Ano | Integer, > 1800 | `1999` | `abc`, `800` |
| Diretor | Presente, String | `Nolan` | ` ` (vazio) |
| Categoria ID | Integer, existente | `1` | `999` (não existe) |
| TMDB ID | Integer ou vazio | `603`, ` ` | `abc` |

### **Validações Automáticas:**

- ✅ **Duplicatas:** Verifica se filme já existe (por título + ano)
- ✅ **Categoria:** Verifica se `categoria_id` existe no banco
- ✅ **Encoding:** Suporta UTF-8 (acentos, caracteres especiais)

### **Mensagens de Erro Comuns:**

```
Linha 5: Título não pode ficar em branco
Linha 8: Ano deve ser um número maior que 1800
Linha 12: Diretor não pode ficar em branco
Linha 15: Categoria não encontrada (ID: 999)
Linha 20: Filme já existe: Matrix (1999)
```

---

## 📧 Notificações por Email

### **Email de Conclusão:**

**Assunto:** `Importação #123 Concluída`

**Conteúdo:**
```
Olá [Nome do Usuário],

Sua importação #123 foi concluída!

Resultados:
✅ 15 filmes importados com sucesso
❌ 3 filmes com erros

Detalhes:
- Total de linhas: 18
- Taxa de sucesso: 83%
- Tempo de processamento: 2min 34s

Veja os detalhes em:
http://cinelog.com/importacoes/123

---
Equipe Cinelog
```

### **Relatório de Erros (Anexo):**

```
RELATÓRIO DE ERROS - IMPORTAÇÃO #123
Data: 2024-10-25 18:30:45

LINHA 5:
- Título não pode ficar em branco

LINHA 8:
- Ano deve ser um número válido

LINHA 12:
- Categoria não encontrada (ID: 999)

---
Total de erros: 3
```

---

## 🐛 Troubleshooting

### **Problema: "CSV com encoding inválido"**

**Causa:** Arquivo não está em UTF-8

**Solução:**
```powershell
# Converter para UTF-8 no PowerShell
Get-Content -Path arquivo.csv -Encoding Latin1 | `
  Set-Content -Path arquivo_utf8.csv -Encoding UTF8
```

### **Problema: "TMDB ID não encontra filme"**

**Causa:** ID incorreto ou filme não existe no TMDB

**Solução:**
- Verifique ID no site do TMDB
- Deixe campo vazio para busca por título

### **Problema: "Categoria não encontrada"**

**Causa:** ID de categoria não existe no banco

**Solução:**
```ruby
rails console

# Criar categoria faltando
Categoria.create!(nome: 'Documentário', descricao: 'Filmes documentários')

# Ver todas categorias
Categoria.pluck(:id, :nome)
```

### **Problema: "Importação fica em 'Pendente' para sempre"**

**Causa:** Sidekiq/ActiveJob não está processando

**Solução:**
- Em **desenvolvimento**: Jobs processam automaticamente (`:async`)
- Em **produção**: Verifique se Sidekiq está rodando
  ```powershell
  bundle exec sidekiq -C config/sidekiq.yml
  ```

### **Problema: "Poster não baixa"**

**Causa:** TMDB_API_KEY não configurada ou inválida

**Solução:**
```env
# .env
TMDB_API_KEY=sua_chave_aqui
```

---

## 📝 Criar Arquivo de Exemplo

### **Script Gerador (Ruby):**

```ruby
# tmp/gerar_csv_exemplo.rb
require 'csv'

filmes = [
  ['Matrix', 1999, 'Lana Wachowski', 'Ficção Científica', 'Um hacker descobre a verdade', 1, 603],
  ['Inception', 2010, 'Christopher Nolan', 'Thriller', 'Um ladrão invade sonhos', 1, 27205],
  ['Parasite', 2019, 'Bong Joon-ho', 'Drama', 'Uma família se infiltra', 2, 496243],
  ['Interstellar', 2014, 'Christopher Nolan', 'Ficção Científica', 'Busca por novo lar', 5, 157336],
  ['The Dark Knight', 2008, 'Christopher Nolan', 'Ação', 'Batman vs Coringa', 1, 155]
]

CSV.open('tmp/filmes_exemplo.csv', 'w') do |csv|
  csv << ['titulo', 'ano', 'diretor', 'genero', 'sinopse', 'categoria_id', 'tmdb_id']
  filmes.each { |filme| csv << filme }
end

puts "✅ Arquivo criado: tmp/filmes_exemplo.csv"
```

Execute:
```powershell
rails runner tmp/gerar_csv_exemplo.rb
```

---

## 💡 Dicas e Melhores Práticas

### **Performance:**

- ⚡ Lotes pequenos: Importe 50-100 filmes por vez
- ⚡ Use `tmdb_id`: Busca 10x mais rápida que por título
- ⚡ Pré-valide CSV: Use ferramentas como Excel/Google Sheets

### **Qualidade dos Dados:**

- 🎯 **tmdb_id obrigatório**: Para dados precisos e posters
- 🎯 **Categorias corretas**: Verifique IDs antes de importar
- 🎯 **Encoding UTF-8**: Salve sempre com esse formato
- 🎯 **Teste com amostra**: Importe 5 linhas primeiro

### **Monitoramento:**

```ruby
# Ver importações recentes
Importacao.order(created_at: :desc).limit(10)

# Ver taxa de sucesso
importacoes = Importacao.where(status: 'concluida')
taxa = (importacoes.sum(:linhas_sucesso).to_f / importacoes.sum(:total_linhas) * 100).round(2)
puts "Taxa de sucesso: #{taxa}%"

# Ver filmes importados hoje
Filme.where('created_at > ?', Date.today).count
```

### **Limpeza:**

```ruby
# Deletar importações antigas
Importacao.where('created_at < ?', 3.months.ago).destroy_all

# Deletar arquivos antigos (Active Storage)
ActiveStorage::Blob.unattached.where('created_at < ?', 1.week.ago).find_each(&:purge)
```

---

## 📚 Referências

- **API TMDB:** https://developers.themoviedb.org/3/
- **RFC 4180 (CSV):** https://tools.ietf.org/html/rfc4180
- **Active Storage:** https://guides.rubyonrails.org/active_storage_overview.html
- **ActiveJob:** https://guides.rubyonrails.org/active_job_basics.html

---

**Pronto para importar centenas de filmes em minutos! 🚀**
