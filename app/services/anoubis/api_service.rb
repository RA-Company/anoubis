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

  # @!attribute result
  #   @return [Anoubis::Result] result
  attr_accessor :result

  ##
  # Initialize service
  # @param api_url [String] base API url
  # @param auth [String] string for apply to authorization header
  def initialize(api_url, auth = nil, result = nil)
    @api_url = api_url
    @auth = auth
    @result = result
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

    used_url = "#{@api_url}#{url}"

    begin
      response = RestClient::Request.execute(
        method: method,
        url: used_url,
        payload: payload.to_json,
        headers: headers,
        timeout: timeout,
        open_timeout: timeout
      )
    rescue StandardError => e
      @error = e
      @result.result = :incorrect_response if @result
      Rails.logger.error "  Anoubis::ApiService request error for URL #{used_url}: #{e}"
      return nil
    end

    return nil unless response.code == 200

    begin
      data = JSON.parse response.body,{ symbolize_names: true }
    rescue StandardError => e
      @error = e
      @result.result = :incorrect_json_data if @result
      Rails.logger.error "  Anoubis::ApiService error parsing JSON data for URL #{used_url}: #{e}"
      return nil
    end

    data
  end
end