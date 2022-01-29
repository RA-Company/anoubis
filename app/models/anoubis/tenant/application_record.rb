##
# Default ApplicationRecord for Anoubis::Core library.
class Anoubis::Tenant::ApplicationRecord < Anoubis::Core::ApplicationRecord
  self.abstract_class = true

  before_update :before_update_tenant_anoubis_model
  before_create :before_create_tenant_anoubis_model

  ##
  # Returns the default ActiveRecord 'where' for defined model.
  # @param object [ApplicationController] pointer to used Application controller
  # @param pid [Integer] parent model id if present (default: 0). Variable doesn't necessary
  # @return [Hash] ActiveRecord 'where' definition
  def self.get_where(object, pid = 0)
    if self.has_attribute? :tenant_id
      return { tenant_id: object.current_user.tenant_id }
    else
      return {}
    end
  end

  ##
  # Is called before data will be updated in database. Prevents changing tenant
  def before_update_tenant_anoubis_model
    begin
      self.tenant_id = self.tenant_id_was
    rescue

    end
  end

  ##
  # Is called before data will be created in database. Sets tenant according by current user
  def before_create_tenant_anoubis_model
    begin
      self.tenant_id = self.current_user.tenant_id
    rescue

    end
  end
end