## Main application model record class inherited from {https://api.rubyonrails.org/classes/ActiveRecord/Base.html ActiveRecord::Base}
class Anoubis::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_initialize :initialize_anubis_application_record

  ## Redis database variable
  attr_accessor :redis

  # @!attribute [rw] need_refresh
  #   @return [Boolean] defines when table representation data should be updated even after simple update
  attr_accessor :need_refresh

  ##
  # Fires after ApplicationRecord initialized for define default values
  def initialize_anubis_application_record
    self.need_refresh = false

    after_initialize_anubis_application_record
  end

  ##
  # Fires after initialize default variables
  def after_initialize_anubis_application_record

  end

  ##
  # Returns {https://github.com/redis/redis-rb Redis database} class
  # @return [Class] {https://github.com/redis/redis-rb Redis} class reference
  def redis
    @redis ||= Redis.new
  end

  ##
  # Returns {https://github.com/redis/redis-rb Redis database} class
  # @return [Class] {https://github.com/redis/redis-rb Redis} class reference
  def self.redis
    Redis.new
  end

  ##
  # Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data. Prefix can be set in Rails.configuration.anoubis_redis_prefix configuration parameter.
  # @return [String] {https://github.com/redis/redis-rb Redis} prefix
  def redis_prefix
    begin
      value = Rails.configuration.anoubis_redis_prefix
    rescue
      return ''
    end
    return value + ':'
  end

  ##
  # Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data. Prefix can be set in Rails.configuration.anoubis_redis_prefix configuration parameter.
  # @return [String] {https://github.com/redis/redis-rb Redis} prefix
  def self.redis_prefix
    begin
      value = Rails.configuration.anoubis_redis_prefix
    rescue
      return ''
    end
    return value + ':'
  end

  ##
  # Return defined locale according by I18n
  # @return [String] current locale
  def current_locale
    I18n.locale.to_s
  end

  ##
  # Returns {current_locale}. If current locale isn't set then returns {default_locale}.
  # @return [String] current locale
  def get_locale
    if current_locale && current_locale != ''
      return current_locale
    end

    default_locale
  end

  ##
  # Default locale that setup in Rails.configuration.i18n.default_locale configuration parameter
  # @return [String] default locale
  def default_locale
    Rails.configuration.i18n.default_locale.to_s
  end

  ##
  # Returns localized field by identifier
  # @param field [String] Field identifier
  # @param used_locale [String | nil] Locale identifier (by default used {current_locale})
  # @return [String] localized field
  def get_locale_field(field, used_locale = nil)
    field = field.to_s.to_sym
    used_locale = current_locale.to_s unless used_locale

    return '' unless self[field]
    return self[field][used_locale] if self[field].key? used_locale
    return '' unless self[field].key? default_locale.to_s

    self[field][default_locale.to_s]
  end

  ##
  # Sets localized data
  # @param field [String] field identifier
  # @param value [String] localized string
  # @param used_locale [String | nil] Locale identifier (by default used {current_locale})
  def set_locale_field(field, value, used_locale = nil)
    field = field.to_s.to_sym
    used_locale = current_locale.to_s unless used_locale

    self[field] = {} unless self[field]
    self[field][default_locale.to_s] = value unless self[field].key? default_locale.to_s
    self[field][used_locale] = value
  end

  ##
  # Returns true if field has localized data
  # @param field [String] Field identifier
  # @param used_locale [String | nil] Locale identifier (by default used {current_locale})
  # @return [Boolean] true if field has localized data
  def is_field_localized(field, used_locale = nil)
    field = field.to_s.to_sym
    used_locale = current_locale.to_s unless used_locale

    return false unless self[field]
    return true if self[field].key? used_locale

    false
  end

  ##
  # Checks if this record may be destroyed.
  def can_destroy?
    result = true
    self.class.reflect_on_all_associations.all? do |assoc|
      result = self.send(assoc.name).nil? if assoc.macro == :has_one
      result = self.send(assoc.name).empty? if (assoc.macro == :has_many) && result
    end
    result
  end

  ##
  # Returns system title of table element
  # @return [String] System title
  def sys_title
    id.to_s
  end

  ##
  # Returns the ability to create new data. By default all items may be deleted. For another result
  # procedure should be overridden.
  # @param args [Hash] transferred parameters
  # @option args [String] :controller Called controller identifier
  # @option args [String] :tab Called controller tab element
  # @return [Boolean] true if new data may be created.
  def can_new(args = {})
    true
  end

  ##
  # Returns the ability to edit the data. By default all items may be edited. For another result
  # procedure should be overridden.
  # @param args [Hash] transferred parameters
  # @option args [String] :controller Called controller identifier
  # @option args [String] :tab Called controller tab element
  # @return [Boolean] true if data may be edited
  def can_edit(args = {})
    true
  end

  ##
  # Returns the ability to delete a data. By default all items may be deleted. For another result
  # procedure should be overridden.
  # @param args [Hash] transferred parameters
  # @option args [String] :controller Called controller identifier
  # @option args [String] :tab Called controller tab element
  # @return [Boolean] true if data may be deleted
  def can_delete(args = {})
    true
  end
end
