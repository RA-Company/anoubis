##
# API result model for output information
class Anoubis::Result
  ##
  # Default error messages
  MESSAGES = {
    success: I18n.t('anoubis.messages.success'),
    custom_result: '', # -1
    unknown: I18n.t('anoubis.errors.unknown'), # -2
    incorrect_parameters: I18n.t('anoubis.errors.incorrect_parameters'), # -3
    cant_create_data: I18n.t('anoubis.errors.cant_create_data'), # -4
    cant_update_data: I18n.t('anoubis.errors.cant_update_data'), # -5
    cant_destroy_data: I18n.t('anoubis.errors.cant_destroy_data'), # -6
    create_is_not_allowed: I18n.t('anoubis.errors.create_is_not_allowed'), # -7
    update_is_not_allowed: I18n.t('anoubis.errors.update_is_not_allowed'), # -8
    destroy_is_not_allowed: I18n.t('anoubis.errors.destroy_is_not_allowed'), # -9
    incorrect_login: I18n.t('anoubis.errors.incorrect_login'), # -10
    session_was_expired: I18n.t('anoubis.errors.session_was_expired'), # -11
    required_new_login: I18n.t('anoubis.errors.required_new_login'), # -12
    incorrect_response: I18n.t('anoubis.errors.incorrect_response'), # -13
    incorrect_json_data: I18n.t('anoubis.errors.incorrect_json_data'), # -14
    access_denied: I18n.t('anoubis.errors.access_denied'), # -15
    reserved_16: '',
    reserved_17: '',
    reserved_18: '',
    reserved_19: '',
    reserved_20: '',
    reserved_21: '',
    reserved_22: '',
    reserved_23: '',
    reserved_24: '',
    reserved_25: '',
    reserved_26: '',
    reserved_27: '',
    reserved_28: '',
    reserved_29: ''
  }

  # @!attribute data
  #   @return [Array | Hash] result data if it's presented in API response
  attr_accessor :data

  # @!attribute error
  #   @return [Array | Hash] result error messages if it's presented in API response
  attr_accessor :errors

  # @!attribute custom_result
  #   @return [String] custom result message text
  attr_accessor :custom_result

  def initialize(msg = {})
    @messages = MESSAGES.merge(msg)

    @result = :success
    @custom_result = nil
    @errors = nil
    @data = nil
  end

  ##
  # Set result parameter
  # @param value [Symbol] error symbol
  def result=(value)
    value = :unknown if value.to_sym == :custom_result
    @result = @messages.key?(value) ? value : :unknown
  end

  ##
  # Returns result error number (0 if success)
  # @return [Integer] error number
  def result
    -@messages.keys.index(@result)
  end

  ##
  # Set custom result text
  # @param value [String] custom result message text
  def custom_result=(value)
    @result = :custom_result
    @custom_result = value
  end

  ##
  # Returns result text message
  # @return [String] result text message
  def message
    return @custom_result if @result == :custom_result

    @messages[@result]
  end

  ##
  # Returns Hash representation of result
  def as_json
    res = {
      result: result,
      message: message
    }
    res[:data] = data if data
    res[:errors] = errors if errors

    res
  end

  ##
  # Returns Json representation of result
  def to_json
    as_json.to_json
  end
end