##
# Localization for {System} model. Model stores all translations for {System} model.
class Anoubis::Tenant::SystemLocale < Anoubis::Core::ApplicationRecord
  # Redefines default table name
  self.table_name = 'system_locales'

  # @!attribute title
  #   @return [String] the system's localized title
  validates :title, length: { minimum: 3, maximum: 100 }, uniqueness: { scope: [:system_id, :locale] }

  # @!attribute system
  #   @return [System] reference to the {System} model
  belongs_to :system, :class_name => 'Anoubis::Tenant::System'
  validates :system, presence: true, uniqueness: { scope: [:locale] }

  # @!attribute locale
  #   @return [Locales] reference to locale
  enum locale: Anoubis::Core::Locales.enums
end