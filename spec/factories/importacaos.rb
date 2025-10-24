FactoryBot.define do
  factory :importacao do
    association :usuario
    arquivo { Rails.root.join('tmp', "test_#{SecureRandom.hex(8)}.csv").to_s }
    status { Importacao::STATUS_PENDENTE }
    total_linhas { nil }
    criados { nil }
    falhas { nil }
    erros { nil }

    # Factory para importação concluída
    trait :concluida do
      status { Importacao::STATUS_CONCLUIDO }
      total_linhas { 10 }
      criados { 10 }
      falhas { 0 }
    end

    # Factory para importação com falhas
    trait :com_falhas do
      status { Importacao::STATUS_CONCLUIDO }
      total_linhas { 10 }
      criados { 7 }
      falhas { 3 }
      erros { "Linha 2: Título não pode estar vazio\nLinha 5: Erro de validação\nLinha 8: Dados inválidos" }
    end

    # Factory para importação que falhou completamente
    trait :falhou do
      status { Importacao::STATUS_FALHA }
      erros { "Arquivo CSV malformado" }
    end
  end
end
