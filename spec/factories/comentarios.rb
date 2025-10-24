FactoryBot.define do
  factory :comentario do
    conteudo { 'Comentário exemplo' }
    nome_autor { 'Anonimo' }
    association :filme, factory: :filme
    association :usuario, factory: :usuario
  end
end
