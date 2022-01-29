class Anoubis::Sso::Client::Group < Anoubis::Sso::Client::ApplicationRecord
  self.table_name = 'groups'

  VALID_IDENT_REGEX = /\A[a-z]*\z/i

  # @!attribute ident
  #   @return [String] the group's identifier. Identifier consists of lowercase alphabetical symbols.
  validates :ident, length: { minimum: 3, maximum: 50 }, uniqueness: { case_sensitive: false }, format: { with: VALID_IDENT_REGEX }

  validates :title, presence: true, length: { maximum: 100 }

  def title
    get_locale_field 'title_locale'
  end

  def title=(value)
    self.set_locale_field 'title_locale', value
  end
end