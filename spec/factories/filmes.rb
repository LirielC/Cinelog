FactoryBot.define do
  factory :filme do
    sequence(:titulo) { |n| "Filme #{n}" }
    sinopse { 'Sinopse exemplo' }
    ano_lancamento { 2020 }
    duracao_minutos { 120 }
    diretor { 'Diretor Exemplo' }
    association :usuario, factory: :usuario
  end
end
