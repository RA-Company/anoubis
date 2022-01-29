##
# Default ApplicationRecord for Anubis::Core library.
class Anubis::Core::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # @!attribute created_at
  #   @return [DateTime] the date and time when item had been created

  # @!attribute updated_at
  #   @return [DateTime] the date and time when item had been updated

  # @!attribute redis
  #   @return [Object] pointer to Redis database
  class_attribute :redis

  # @!attribute [rw] current_user
  #   @return [String] definition of current user for this record
  attr_accessor :current_user

  # @!attribute [rw] need_refresh
  #   @return [Boolean] defines when table representation data should be updated even after simple update
  class_attribute :need_refresh, default: false

  # @!attribute [r] sys_title
  attr_reader :sys_title

  # @!attribute [r] can_new
  attr_reader :can_new

  # @!attribute [r] can_edit
  attr_reader :can_edit

  # @!attribute [r] can_delete
  attr_reader :can_delete

  after_initialize :after_initialize_core_anubis_model
  before_validation :before_validation_core_anubis_model

  public

  ##
  # Is called after initialization Anubis::Core ActiveRecord. Sets default parameters.
  def after_initialize_core_anubis_model
    self.need_refresh = false
    self.redis = Redis.new
    self.current_user = nil
  end

  ##
  # Return defined locale according by I18n
  def current_locale
    I18n.locale.to_s
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
  # Returns the default ActiveRecord 'where' for defined model.
  # @param object [ApplicationController] pointer to used Application controller
  # @param pid [Integer] parent model id if present (default: 0). Variable doesn't necessary
  # @return [Hash] ActiveRecord 'where' definition
  def self.get_where(object, pid = 0)
    { }
  end

  ##
  # Returns model's system title. Default value is the row ID. For another result procedure should be overridden.
  # @return [String] model's system title
  def sys_title
    self.id
  end

  ##
  # Returns the ability to create new data. By default all items may be deleted. For another result
  # procedure should be overridden.
  # @return [Boolean] true if new data may be created.
  def can_new(args = {})
    true
  end

  ##
  # Returns the ability to edit the data. By default all items may be edited. For another result
  # procedure should be overridden.
  # @return [Boolean] true if data may be edited
  def can_edit(args = {})
    true
  end

  ##
  # Returns the ability to delete a data. By default all items may be deleted. For another result
  # procedure should be overridden.
  # @return [Boolean] true if data may be deleted
  def can_delete(args = {})
    true
  end

  ##
  # Sets current locale and nullifies locale variable that presents model translation data.
  # @param value [String] new locale value ('ru', 'en', etc)
  def current_locale=(value)
    @current_locale = value
    @model_locale = nil
  end

  private

  ##
  # Is called before validation model's data. Sets user id of user that modify model's data
  # (if updated_user_id field presents in database)
  def before_validation_core_anubis_model
    begin
      self.updated_user_id = self.current_user.id if self.current_user
    rescue

    end
  end

  protected

  ##
  # Returns text that was converted for russian quotes.
  # @param str [String] - source text
  # @return [String] converted text
  def convert_russian_quotes(str)
    return str.gsub(/^"/, "«").gsub(/ "/, " «").gsub(/«"/, "««").gsub(/" /, "» ").gsub(/"$/, "»").gsub(/"»/, "»»")
  end

  ##
  # @!group Block of UUID functions

  ##
  # Decodes binary UUID data into the UUID string
  # @param data [Binary] binary representation of UUID
  # @return [String, nil] string representation of UUID or nil if can't be decoded
  def bin_to_uuid(data)
    begin
      data = data.unpack('H*')[0]
      return data[0..7]+'-'+data[8..11]+'-'+data[12..15]+'-'+data[16..19]+'-'+data[20..31]
    rescue
      return nil
    end
  end

  ##
  # Encodes string UUID data into the binary UUID
  # @param data [Binary] string representation of UUID
  # @return [Binary, nil] binary representation of UUID or nil if can't be encoded
  def uuid_to_bin(data)
    begin
      return [data.delete('-')].pack('H*')
    rescue
      return nil
    end
  end

  public

  ##
  # Generates new UUID data
  # @return [String] string representation of UUID
  def new_uuid
    SecureRandom.uuid
  end

  # @!endgroup

  ##
  # @!group Block of Redis functions

  ##
  # Returns defined application prefix for redis cache for current record. Default value ''
  def redis_prefix
    begin
      value = Rails.configuration.redis_prefix
    rescue
      return ''
    end
    return value + ':'
  end

  ##
  # Returns defined application prefix for redis cache for model. Default value ''
  def self.redis_prefix
    begin
      value = Rails.configuration.redis_prefix
    rescue
      return ''
    end
    return value + ':'
  end

  ##
  # Returns reference to Redis database
  def self.redis
    Redis.new
  end

  # @!endgroup

  def get_locale
    if self.current_locale && self.current_locale != ''
      return self.current_locale
    end

    self.default_locale
  end

  def default_locale
    Rails.configuration.i18n.default_locale.to_s
  end

  def get_locale_field(field, used_locale = nil)
    field = field.to_s.to_sym
    used_locale = self.current_locale.to_s unless used_locale

    return '' unless self[field]
    return self[field][used_locale] if self[field].key? used_locale
    return '' unless self[field].key? self.default_locale.to_s

    self[field][self.default_locale.to_s]
  end

  def set_locale_field(field, value, used_locale = nil)
    field = field.to_s.to_sym
    used_locale = self.current_locale.to_s unless used_locale

    self[field] = {} unless self[field]
    self[field][self.default_locale.to_s] = value unless self[field].key? self.default_locale.to_s
    self[field][used_locale] = value
  end

  def is_field_localized(field, used_locale = nil)
    field = field.to_s.to_sym
    used_locale = self.current_locale.to_s unless used_locale

    return false unless self[field]
    return true if self[field].key? used_locale

    false
  end
end
