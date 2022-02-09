require 'rails_helper'

module Anoubis
  RSpec.describe Group, type: :model do
    it "is valid" do
      expect(build_stubbed(:group)).to be_valid
    end

    it "has short ident" do
      expect(build_stubbed(:group, ident: 'T'*2)).to be_invalid
    end

    it "has long ident" do
      expect(build_stubbed(:group, ident: 'T'*51)).to be_invalid
    end

    it "has invalid ident" do
      expect(build_stubbed(:group, ident: '1'*5)).to be_invalid
    end

    it "has duplicated ident" do
      system = create :system
      create :group, system: system
      expect(build(:group, system: system)).to be_invalid
    end

    it "can change group" do
      group = create :group
      group.ident = 'wrkt'
      expect(group.save).to eq true
    end

    it "can't change admin group ident" do
      system = create :system
      group = Anoubis::Group.where(system: system, ident: 'admin').first
      group.ident = 'tst'
      expect(group.save).to eq false
    end

    it "can destroy" do
      group = create :group, ident: 'dst'
      group.destroy
      expect(group.destroyed?).to eq true
    end

    it "can't destroy admin group of main system" do
      group = Anoubis::Group.where(system_id: 1, ident: 'admin').first
      group.destroy
      expect(group.destroyed?).to eq false
    end
  end
end
