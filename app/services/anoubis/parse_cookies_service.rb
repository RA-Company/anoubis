##
# Service for parsing browser cookies string to cookies Hash
class Anoubis::ParseCookiesService < Anoubis::ApplicationService
  ##
  # Transform cookies string to hash
  # @param str [String] Cookies string
  # @return [Hash] Cookies data
  def call(str)
    cookies = { }

    arr = str.split('; ')
    arr.each do |line|
      index = line.index '='
      if index
        key = line[0..(index - 1)]
        value = line[(index + 1)..(line.length - 1)]
      end
      cookies[key.to_s.to_sym] = value.to_s
    end

    cookies
  end
end