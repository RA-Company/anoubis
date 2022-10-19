##
# Service for unzip {https://www.rubydoc.info/gems/rest-client/RestClient RestClient} response data if returned data is GZipped
class Anoubis::UnzipService < Anoubis::ApplicationService
  ##
  # Unzip {https://www.rubydoc.info/gems/rest-client/RestClient RestClient} response data if returned data is GZipped
  # @param response [RestClient::RawResponse] Received {https://www.rubydoc.info/gems/rest-client/RestClient/RawResponse RestClient::RawResponse}
  # @return [String] unzipped string or nil if data can't be unzipped
  def call(response)
    result = response.body
    begin
      if response.headers.key? :content_encoding
        if response.headers[:content_encoding] == 'gzip'
          sio = StringIO.new(response.body)
          gz = Zlib::GzipReader.new(sio)
          result = gz.read()
        end
      else
        result = response.body
      end
    rescue => e
      result = nil
    end

    result
  end
end