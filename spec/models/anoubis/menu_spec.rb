require 'rails_helper'

module Anubis
  RSpec.describe Menu, type: :model do
    it "is valid" do
      expect(build_stubbed(:menu)).to be_valid
    end

    it "has no action" do
      expect(build_stubbed(:menu, action: nil)).to be_invalid
    end

    it "has no mode" do
      expect(build_stubbed(:menu, mode: nil)).to be_invalid
    end

    it "has dublicate mode" do
      create :menu
      expect(build_stubbed(:menu)).to be_invalid
    end

    it "has invalid position" do
      menu = create :menu
      menu.position = 'dd'
      expect(menu.save).to eq false
    end

    it "can change data" do
      menu = create :menu
      menu.mode = 'tst_data'
      expect(menu.save).to eq true
    end

    it "can change position" do
      menu1 = create :menu
      menu2 = create :menu, mode: 'test2'
      menu3 = create :menu, mode: 'test3'
      menu3.position = menu1.position
      expect(menu3.save).to eq true
    end

    it "can destroy" do
      menu = create :menu
      menu.destroy
      expect(menu.destroyed?).to eq true
    end
  end
end
