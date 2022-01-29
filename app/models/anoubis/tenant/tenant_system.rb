##
# Model for links Tenant and System models
class Anoubis::Tenant::TenantSystem < ApplicationRecord
  self.table_name = 'tenant_systems'

  before_update :before_update_tenant_system

  belongs_to :tenant, class_name: 'Anoubis::Tenant::Tenant'
  validates :tenant, presence: true, uniqueness: { scope: [:system_id] }
  belongs_to :system, class_name: 'Anoubis::Tenant::System'
  validates :system, presence: true, uniqueness: { scope: [:tenant_id] }

  ##
  # Checks before update data in model. Prevents from changing element data
  def before_update_tenant_system
    self.tenant_id = self.tenant_id_was if self.tenant_id_changed?
    self.system_id = self.system_id_was if self.system_id_changed?
  end
end