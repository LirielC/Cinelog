# Configurações de inflexão para palavras em português
ActiveSupport::Inflector.inflections(:en) do |inflect|
  # Plural irregular: importacao -> importacoes
  inflect.irregular 'importacao', 'importacoes'
end
