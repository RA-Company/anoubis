require 'rails_helper'

module Anubis
  RSpec.describe SystemMenu, type: :model do
    before(:all) do
      @system = create :system, ident: 'test'
      #@group = create :group, ident: 'test', title: 'Test', system: @system
      @menu1 = create :menu, mode: 'menu1', action: 'data'
      @menu2 = create :menu, mode: 'menu2', action: 'data', menu: @menu1
      @menu3 = create :menu, mode: 'menu3', action: 'data', menu: @menu2
    end

    it "can create" do
      expect(build_stubbed(:system_menu, system: @system, menu: @menu1)).to be_valid
    end

    it "can create tree" do
      expect(build_stubbed(:system_menu, system: @system, menu: @menu3)).to be_valid
    end

    it "check created tree" do
      create :system_menu, system: @system, menu: @menu3
      expect(Anubis::SystemMenu.where(system: @system).count(:id)).to eq 3
    end

    it "can destroy" do
      data = create :system_menu, system: @system, menu: @menu1
      data.destroy
      expect(data.destroyed?).to eq true
    end

    it "can destroy tree" do
      create :system_menu, system: @system, menu: @menu3
      Anubis::SystemMenu.where(system: @system, menu: @menu1).first.destroy
      expect(Anubis::SystemMenu.where(system: @system).count(:id)).to eq 0
    end

    after(:all) do
      @menu3.destroy
      @menu2.destroy
      @menu1.destroy
      #@group.destroy
      Anubis::Group.where(system_id: @system.id).each do |item|
        item.destroy
      end
      @system.destroy
    end
  end
end
