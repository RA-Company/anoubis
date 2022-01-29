FactoryBot.define do
  factory :system_locale, class: 'Anoubis::SystemLocale' do
    system
    locale { 'en' }
    title { 'System Title' }
  end
end
