##
# UserGroup model. It links User and Group models.
class Anoubis::Sso::Client::UserGroup < Anoubis::Sso::Client::ApplicationRecord
  self.table_name = 'user_groups'

  before_update :before_update_sso_client_user_group
  after_create :after_modify_sso_client_user_group
  after_destroy :after_modify_sso_client_user_group

  belongs_to :group, class_name: 'Anoubis::Sso::Client::Group'
  validates :group, presence: true, uniqueness: { scope: [:user_id] }
  belongs_to :user, class_name: 'Anoubis::Sso::Client::User'
  validates :user, presence: true, uniqueness: { scope: [:group_id] }

  ##
  # Can't change elements
  def before_update_sso_client_user_group
    self.user_id = self.user_id_was if self.user_id_changed?
    self.group_id = self.group_id_was if self.group_id_changed?
  end

  ##
  # Delete all redis keys of menu for defined user
  def after_modify_sso_client_user_group
    if self.redis
      self.redis.keys(self.redis_prefix + self.user.uuid.to_s + '_*').each do |data|
        self.redis.del data
      end
      self.redis.del self.redis_prefix + 'user:' + self.user.uuid.to_s
    end
  end
end