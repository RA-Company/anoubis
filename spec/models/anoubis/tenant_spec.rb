require 'rails_helper'

module Anubis
  RSpec.describe Tenant, type: :model do
    it "is valid" do
      expect(build_stubbed(:tenant)).to be_valid
    end

    it "has short title" do
      expect(build_stubbed(:tenant, title: 'T'*2)).to be_invalid
    end

    it "has long title" do
      expect(build_stubbed(:tenant, title: 'T'*101)).to be_invalid
    end

    it "has short ident" do
      expect(build_stubbed(:tenant, ident: 'T'*2)).to be_invalid
    end

    it "has long ident" do
      expect(build_stubbed(:tenant, ident: 'T'*11)).to be_invalid
    end

    it "has invalid ident" do
      expect(build_stubbed(:tenant, ident: '1'*5)).to be_invalid
    end

    it "has duplicated title" do
      create :tenant
      expect(build_stubbed(:tenant, ident: 'T'*5)).to be_invalid
    end

    it "has duplicated ident" do
      create :tenant
      expect(build_stubbed(:tenant, title: 'T'*10)).to be_invalid
    end

    it "can change tenant" do
      tenant = create :tenant
      tenant.title = 'Work Tenant Test'
      tenant.ident = 'wrkt'
      expect(tenant.save).to eq true
    end

    it "can't change system tenant ident" do
      tenant = Anubis::Tenant.find(1)
      tenant.ident = 'tst'
      expect(tenant.save).to eq false
    end

    it "can destroy" do
      tenant = create :tenant, title: 'Destroy', ident: 'dst'
      Anubis::TenantSystem.where(tenant_id: tenant.id).each do |item|
        item.destroy
      end
      tenant.destroy
      expect(tenant.destroyed?).to eq true
    end

    it "can't destroy system tenant" do
      tenant = Anubis::Tenant.find(1)
      tenant.destroy
      expect(tenant.destroyed?).to eq false
    end
  end
end
