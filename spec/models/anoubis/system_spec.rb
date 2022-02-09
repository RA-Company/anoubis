require 'rails_helper'

module Anoubis
  RSpec.describe System, type: :model do
    it "is valid" do
      expect(build_stubbed(:system)).to be_valid
    end

    it "has short ident" do
      expect(build_stubbed(:system, ident: 'T'*2)).to be_invalid
    end

    it "has long ident" do
      expect(build_stubbed(:system, ident: 'T'*16)).to be_invalid
    end

    it "has invalid ident" do
      expect(build_stubbed(:system, ident: '1'*5)).to be_invalid
    end

    it "has duplicated ident" do
      create :system
      expect(build_stubbed(:system)).to be_invalid
    end

    it "can change system" do
      system = create :system
      system.ident = 'wrkt'
      expect(system.save).to eq true
    end

    it "can't change main system ident" do
      system = Anoubis::System.find(1)
      system.ident = 'tst'
      expect(system.save).to eq false
    end

    it "can destroy" do
      system = create :system, ident: 'dst'
      Anoubis::Group.where(system_id: system.id).each do |item|
        item.destroy
      end
      system.destroy
      expect(system.destroyed?).to eq true
    end

    it "can't destroy main system" do
      system = Anoubis::System.find(1)
      system.destroy
      expect(system.destroyed?).to eq false
    end
  end
end
