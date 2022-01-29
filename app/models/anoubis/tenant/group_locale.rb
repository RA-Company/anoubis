##
# Localization for {Group} model. Model stores all translations for {Group} model.
class Anoubis::Tenant::GroupLocale < Anoubis::Core::ApplicationRecord
  # Redefines default table name
  self.table_name = 'group_locales'

  # @!attribute title
  #   @return [String] the group's localized title
  validates :title, length: { minimum: 3, maximum: 100 }

  # @!attribute menu
  #   @return [Group] reference to the {Group} model
  belongs_to :group, :class_name => 'Anoubis::Tenant::Group'
  validates :group, presence: true, uniqueness: { scope: [:locale] }

  # @!attribute locale
  #   @return [Locales] reference to locale
  enum locale: Anoubis::Core::Locales.enums
end