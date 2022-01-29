FactoryBot.define do
  factory :tenant, class: 'Anoubis::Tenant' do
    title { 'Work Tenant' }
    ident { 'wrk' }
    state { 1 }
  end
end
