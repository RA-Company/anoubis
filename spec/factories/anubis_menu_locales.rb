FactoryBot.define do
  factory :menu_locale, class: 'Anoubis::MenuLocale' do
    menu
    locale { 'en' }
    title { 'Menu Title' }
    page_title { 'Menu Page Title' }
    short_title { 'Menu Short Title' }
  end
end
