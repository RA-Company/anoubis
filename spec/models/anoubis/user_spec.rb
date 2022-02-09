require 'rails_helper'

module Anoubis
  RSpec.describe User, type: :model do
    it "is valid" do
      expect(build_stubbed(:user)).to be_valid
    end

    it "hasn't name" do
      expect(build_stubbed(:user, name: nil)).to be_invalid
    end

    it "hasn't surname" do
      expect(build_stubbed(:user, surname: nil)).to be_invalid
    end

    it "hasn't email" do
      expect(build_stubbed(:user, email: nil)).to be_invalid
    end

    it "has incorrect email" do
      expect(build_stubbed(:user, email: 'T'*10)).to be_invalid
    end

    it "has short pasword" do
      expect(build_stubbed(:user, password: 'T'*4, password_confirmation: 'T'*4)).to be_invalid
    end

    it "has different paswords" do
      expect(build_stubbed(:user, password: 'T'*5, password_confirmation: 'I'*5)).to be_invalid
    end

    it "has duplicated email" do
      tenant = create :tenant
      create :user, tenant: tenant
      expect(build(:user, tenant: tenant)).to be_invalid
    end

    it "can change email" do
      user = create :user
      user.email = 'wrk@wrk.com'
      expect(user.save).to eq true
    end

    it "can destroy user" do
      user = create :user
      user.destroy
      expect(user.destroyed?).to eq true
    end

    it "can't destroy Main Administrator" do
      user = Anoubis::User.find(1)
      user.destroy
      expect(user.destroyed?).to eq false
    end
  end
end
