require 'rails_helper'

module Anoubis
  RSpec.describe GroupLocale, type: :model do
    it "has short title" do
      expect(build_stubbed(:group_locale, title: 'T'*2)).to be_invalid
    end

    it "has long title" do
      expect(build_stubbed(:group_locale, title: 'T'*101)).to be_invalid
    end

    it "can change title" do
      group_locale = create :group_locale
      group_locale.title = 'Work Group Test'
      expect(group_locale.save).to eq true
    end

    it "can destroy" do
      group_locale = create :group_locale, title: 'Destroy'
      group_locale.destroy
      expect(group_locale.destroyed?).to eq true
    end
  end
end
