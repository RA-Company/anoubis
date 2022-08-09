class Anoubis::RedisServices::GetJson < Anoubis::ApplicationService
  include Anoubis::RedisServices::Init

  def initialize(key)
    @key = key
  end

  def call
    get_json
  end

  def get_json
    data = Anoubis::RedisServices::Get.call(@key)

    return nil unless data

    begin
      data = JSON.parse(data, { symbolize_names: true })
    rescue StandardError => e
      data = nil
    end

    data
  end
end