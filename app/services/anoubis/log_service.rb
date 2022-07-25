##
# Graylog logging service
class Anoubis::LogService
  # {https://www.rubydoc.info/gems/gelf/GELF/Notifier GELF::Notifier} service
  attr_accessor :logger
  # Hash of permanent parameters that added before sending data to Graylog server
  attr_accessor :perm

  ##
  # Returns Graylog server URL
  # @return [String] Graylog server URL
  def url
    begin
      value = Rails.configuration.graylog_server
    rescue StandardError
      value = '127.0.0.1'
    end

    value
  end

  ##
  # Returns Graylog server port
  # @return [String] Graylog server port
  def port
    begin
      value = Rails.configuration.graylog_port
    rescue StandardError
      value = 12201
    end

    value
  end

  ##
  # Returns Graylog facility identifier in input source
  # @return [String] Graylog facility identifier
  def facility
    begin
      value = Rails.configuration.graylog_facility
    rescue StandardError
      value = 'Graylog'
    end

    value
  end

  ##
  # Setups basic initialization parameters.
  # @param options [Hash] array of parameters
  def initialize(options = {})
    self.logger = GELF::Notifier.new(url, port, 'WAN', { facility: facility })
    logger.collect_file_and_line = false
    logger.rescue_network_errors = true
    self.perm = {}
  end

  ##
  # Send data to Graylog server
  # @param text [String] Logged text data
  # @param type [String] Log level ('debug', 'error', 'info', 'warn')
  # @param object [Hash] Additional parameters for logged data
  def log(text, type = 'info', object = nil)
    type = 'info' unless %w[info warn error].include? type.downcase
    loc = caller_locations(1, 1).first

    data = {
      short_message: text,
      level: level(type),
      line: loc.lineno,
      file: loc.path
    }

    data.merge!(object) if object
    data.merge!(self.perm)
    logger.notify data
    nil
  end

  ##
  # Returns {https://www.rubydoc.info/github/graylog-labs/gelf-rb/GELF/Levels GELF::Levels} according by type
  # @param type [String] Log level ('debug', 'error', 'info', 'warn')
  # @return [GELF::Levels] GELF::Levels
  def level(type)
    case type
    when 'debug'
      return GELF::DEBUG
    when 'info'
      return GELF::INFO
    when 'warn'
      return GELF::WARN
    when 'error'
      return GELF::ERROR
    end

    GELF::UNKNOWN
  end
end