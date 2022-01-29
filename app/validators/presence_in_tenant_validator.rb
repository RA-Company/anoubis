class PresenceInTenantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value
      if value.class.to_s.index 'ActiveRecord_Associations_CollectionProxy'
        value.each do |dat|
          if record.tenant_id != dat.tenant_id
            record.errors.add(attribute, :not_in_tenant, message: I18n.t('activerecord.errors.models.'+record.model_name.i18n_key.to_s+'.attributes.'+attribute.to_s+'.not_in_tenant', :default => ['activerecord.errors.messages.not_in_tenant'.to_sym]))
            return
          end
        end
      else
        if record.tenant_id != value.tenant_id
          record.errors.add(attribute, :not_in_tenant, message: I18n.t('activerecord.errors.models.'+record.model_name.i18n_key.to_s+'.attributes.'+attribute.to_s+'.not_in_tenant', :default => ['activerecord.errors.messages.not_in_tenant'.to_sym]))
        end
      end
    else
      record.errors.add(attribute, :blank, message: I18n.t('activerecord.errors.models.'+record.model_name.i18n_key.to_s+'.attributes.'+attribute.to_s+'.blank', :default => ['activerecord.errors.messages.blank'.to_sym]))
    end
  end
end