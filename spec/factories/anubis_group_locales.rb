FactoryBot.define do
  factory :group_locale, class: 'Anoubis::GroupLocale' do
    group
    locale { 'en' }
    title { 'Group Title' }
  end
end
