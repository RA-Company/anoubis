FactoryBot.define do
  factory :user, class: 'Anoubis::User' do
    name { 'Test' }
    surname { 'Test' }
    email { 'test@test.com' }
    password { 'password' }
    password_confirmation { 'password' }
    tenant
  end
end
