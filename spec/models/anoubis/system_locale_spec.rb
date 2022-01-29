require 'rails_helper'

module Anubis
  RSpec.describe SystemLocale, type: :model do
    it "has short title" do
      expect(build_stubbed(:system_locale, title: 'T'*2)).to be_invalid
    end

    it "has long title" do
      expect(build_stubbed(:system_locale, title: 'T'*101)).to be_invalid
    end

    it "has duplicated title" do
      system = create :system
      create :system_locale, system: system
      expect(build_stubbed(:system_locale, system: system)).to be_invalid
    end

  end
end
