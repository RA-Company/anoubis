FactoryBot.define do
  factory :menu, class: 'Anoubis::Menu' do
    mode { 'test' }
    action { 'frame' }
  end
end
