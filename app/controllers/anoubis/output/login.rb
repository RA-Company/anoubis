module Anoubis
  module Output
    ##
    # Output subclass that represents data for login action
    class Login < Basic
      ##
      # Output subclass that represents data for login action

      # @!attribute [rw] token
      #   @return [String] the resulting login token.
      class_attribute :token

      # @!attribute [rw] name
      #   @return [String] the name of the user
      class_attribute :name

      # @!attribute [rw] surname
      #   @return [String] the surname of the user
      class_attribute :surname

      # @!attribute [rw] email
      #   @return [String] the email of the user
      class_attribute :email

      # @!attribute [rw] locale
      #   @return [String] the user's locale
      class_attribute :locale

      ##
      # Initializes login output data. Generates default values.
      def initialize
        super
        self.token = ''
        self.name = ''
        self.surname = ''
        self.email = ''
        self.locale = ''
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        return result if self.result != 0
        result.merge!({
                          token: self.token,
                          name: self.name,
                          surname: self.surname,
                          email: self.email,
                          locale: self.locale
                      })
        result
      end

      ##
      # Generates output message based on {#result self.result} variable.
      # @return [String] output message
      def message
        case self.result
        when -1
          return I18n.t('errors.invalid_login_parameters')
        when -2
          return I18n.t('errors.invalid_login_or_password')
        else
          return super
        end
      end
    end
  end
end