class Anoubis::ApiService < Anoubis::ApplicationService
  # @!attribute api_url
  #   @return [String] base API url
  attr_accessor :api_url

  # @!attribute auth
  #   @return [String] string for apply to authorization header
  attr_accessor :auth

  # @!attribute error
  #   @return [StandardError] returned error
  attr_accessor :error

  ##
  # Initialize service
  # @param api_url [String] base API url
  # @param auth [String] string for apply to authorization header
  def initialize(api_url, auth = nil)
    @api_url = api_url
    @auth = auth
  end

  ##
  # Execute API request
  # @param method [Symbol] request method (:get, :post, :delete etc.)
  # @param url [String] additional part of URL
  # @param payload [Hash] payload parameters
  # @param timeout [Integer] request timeout
  # @return [Hash | nil] Request result or nil if request failed
  def call(method, url, payload = {}, timeout = 600)
    headers = {
      'Content-type': 'application/json'
    }

    headers[:Authorization] = @auth

    begin
      response = RestClient::Request.execute(
        method: method,
        url: "#{@api_url}#{url}",
        payload: payload.to_json,
        headers: headers,
        timeout: timeout,
        open_timeout: timeout
      )
    rescue StandardError => e
      @error = e
      puts e
      return nil
    end

    return nil unless response.code == 200

    begin
      data = JSON.parse response.body,{ symbolize_names: true }
    rescue StandardError => e
      @error = e
      puts e
      return nil
    end

    data
  end
end