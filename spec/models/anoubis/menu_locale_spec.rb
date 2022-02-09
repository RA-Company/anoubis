require 'rails_helper'

module Anoubis
  RSpec.describe MenuLocale, type: :model do
    it "has short title" do
      expect(build_stubbed(:menu_locale, title: 'T'*2)).to be_invalid
    end

    it "has long title" do
      expect(build_stubbed(:menu_locale, title: 'T'*101)).to be_invalid
    end

    it "has short page title" do
      expect(build_stubbed(:menu_locale, page_title: 'T'*2)).to be_invalid
    end

    it "has long page title" do
      expect(build_stubbed(:menu_locale, page_title: 'T'*201)).to be_invalid
    end

    it "has long short title" do
      expect(build_stubbed(:menu_locale, short_title: 'T'*201)).to be_invalid
    end

    it "can change data" do
      menu = create :menu_locale
      menu.title = 'Test title 2'
      expect(menu.save).to eq true
    end
  end
end
