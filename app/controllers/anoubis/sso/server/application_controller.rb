class Anoubis::Sso::Server::ApplicationController < Anoubis::Core::ApplicationController
  def user_model
    begin
      model = Rails.configuration.user_model.classify.constantize
    rescue
      model = Anoubis::Sso::Server::User
    end

    model
  end

  def front_url
    Rails.configuration.sso_front_url
  end

  def domain_url
    Rails.configuration.sso_domain_url
  end

  ##
  # Returns user data by UUI
  def get_user_data_by_uuid(uuid)
    begin
      user_data = self.user_model.new(JSON.parse(self.redis.get(self.redis_prefix + 'user:' + uuid), { symbolize_names: true }))
    rescue
      user_data = nil
    end

    unless user_data
      user_data = self.user_model.where(uuid: uuid, status: 'enabled').first

      user_data.save_cache if user_data
    end

    user_data
  end

  ##
  # Format user information to result hash
  def format_user_output(user_data, result)
    result[:uuid] = user_data.uuid
    result[:name] = user_data.name
    result[:surname] = user_data.surname
    result[:login] = user_data.login
    result[:locale] = user_data.locale
    result[:timezone] = user_data.timezone
    result[:timeout] = user_data.timeout
  end
end