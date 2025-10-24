FactoryBot.define do
  factory :usuario do
    sequence(:nome) { |n| "Usuario #{n}" }
    sequence(:email) { |n| "usuario#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    papel { 'usuario' }

    # Traits para diferentes papéis
    trait :admin do
      papel { 'admin' }
      nome { 'Admin Teste' }
    end

    trait :moderador do
      papel { 'moderador' }
      nome { 'Moderador Teste' }
    end
  end
end
