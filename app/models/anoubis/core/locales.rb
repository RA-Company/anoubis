##
# Defines all available locales.
module Anoubis::Core::Locales
  # List of all possible locales.
  LIST = {
    ru: { id: 1, name: 'Russian' },
    en: { id: 2, name: 'English' },
    kz: { id: 3, name: 'Kazakh' }
  }.freeze

  class << self
    ##
    # Returns the title of chosen locale
    # @param key [String] identificator of locale ('ru', 'en', etc.)
    # @return [String] english title of locale
    def name(key)
      LIST[key.to_sym][:name]
    end

    ##
    # Converts list of locales into enum attribute
    # @return [Symbol] return symbols array for all locales.
    def enums
      LIST.reduce({}) { |res, v| res.merge("#{v.first}": v.last[:id]) }
    end
  end
end