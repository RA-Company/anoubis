##
# Service for receive data frm Redis database
class Anoubis::RedisServices::Get < Anoubis::RedisServices::Init
  ##
  # Get data from Redis database and convert it from JSON if necessary
  # @param convert_json [Boolean] convert data from JSON if true
  # @return [Hash | Array | String | nil] data from Redis database
  def call(convert_json = false)
    data = redis.get(key)

    return data unless convert_json

    return nil unless data

    begin
      data = JSON.parse(data, { symbolize_names: true })
    rescue StandardError => e
      data = nil
    end

    data
  end
end