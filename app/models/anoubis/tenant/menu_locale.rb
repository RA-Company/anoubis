##
# Localization for {Menu} model. Model stores all translations for {Menu} model.
class Anoubis::Tenant::MenuLocale < Anoubis::Core::ApplicationRecord
  # Redefines default table name
  self.table_name = 'menu_locales'

  # @!attribute menu
  #   @return [Menu] reference to the {Menu} model
  belongs_to :menu, :class_name => 'Anoubis::Tenant::Menu'
  validates :menu, presence: true, uniqueness: { scope: [:locale] }

  # @!attribute title
  #   @return [String] the menu's localized title
  validates :title,  presence: true, length: { minimum: 3, maximum: 100 }

  # @!attribute page_title
  #   @return [String] the menu's localized page title. Uses in frontend application.
  validates :page_title,  presence: true, length: { minimum: 3, maximum: 200 }

  # @!attribute short_title
  #   @return [String] the menu's localized short title. Uses in frontend application.
  validates :short_title,  length: { maximum: 200 }

  # @!attribute locale
  #   @return [Locales] reference to locale
  enum locale: Anoubis::Core::Locales.enums
end