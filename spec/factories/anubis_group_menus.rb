FactoryBot.define do
  factory :group_menu, class: 'Anoubis::GroupMenu' do
    access { Anoubis::GroupMenu.accesses[:read] }
    menu
    group
  end
end
