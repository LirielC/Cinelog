FactoryBot.define do
  factory :categoria do
    sequence(:nome) { |n| "Categoria #{n}" }
  end
end
