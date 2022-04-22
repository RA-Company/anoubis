module Anoubis
  ##
  # Module contains all procedures and function for output data. Module consists from {Basic}, {Frame}, {Login} and
  # {Menu} classes.
  module Output
    ##
    # Output subclass that represents parametrs for basic requests
    class Basic
      # @!attribute [rw] title
      #   @return [string] the page title of current loaded frame.
      class_attribute :title

      # @!attribute [rw]
      # @return [Hash<string>] hash of messages
      class_attribute :messages

      # @!attribute [rw]
      # @return [Number] controller action output result code.
      # @note Zero value means successful. Negative value means error.
      class_attribute :result, default: 0

      # @!attribute [rw]
      # @return [String] current returned tab
      class_attribute :tab, default: ''

      ##
      # Output class initialization. Sets default class parameters.
      def initialize
        self.title = nil
        self.result = 0
        self.tab = ''
        self.messages = {
            '0': I18n.t('anoubis.success'),
            '-1': I18n.t('errors.access_not_allowed'),
            '-2': I18n.t('errors.incorrect_parameters')
        }
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all class data
      def to_h
        result = {
            result: self.result,
            timestamp: Time.now.to_i,
            message: message
        }
        result[:title] = self.title if self.title
        result[:tab] = self.tab if self.tab != ''
        result
      end

      ##
      # Generates output message based on result variable.
      # @return [String] output message
      def message
        return messages[result.to_s.to_sym] if messages.key? result.to_s.to_sym
        I18n.t('errors.internal_error')
      end

      ##
      # Convert hash to array json output
      # @param hash [Hash] hash representation
      # @return [Array] array representation
      def hash_to_json(hash)
        result = []
        hash.each_key do |key|
          result.push({ key: key.to_s, value: hash[key] })
        end
        result
      end

      ##
      # Convert options hash to array json output
      # @param options [Hash<Hash>] options with hash representation
      # @return [Hash<Array>] options with array representation
      def options_to_json(options)
        result = {}
        options.each_key do |key|
          result[key] = self.hash_to_json(options[key])
        end
        result
      end
    end
  end
end