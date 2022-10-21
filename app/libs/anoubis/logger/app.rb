class Anoubis::Logger::App
  include Singleton

  attr_accessor :level
  attr_accessor :logger

  CRITICAL = 1
  ERROR = 2
  WARNING = 3
  INFO = 4

  def initialize
    begin
      lvl = Rails.configuration.app_logger_level.upcase
    rescue
      lvl = 'WARNING'
    end

    lvl = 'WARNING' unless %w[CRITICAL WARNING ERROR INFO].include? lvl
    @level = eval(lvl)

    begin
      @logger = Object.const_get Rails.configuration.app_logger
    rescue
      @logger = Anoubis::Logger::Console.new
    end
  end

  def critical(msg, obj = nil)
    log msg, CRITICAL, obj
  end

  def error(msg, obj = nil)
    log(msg, ERROR, obj) if @level >= ERROR
  end

  def warning(msg, obj = nil)
    log(msg, WARNING, obj) if @level >= WARNING
  end

  def info(msg, obj = nil)
    log(msg, INFO, obj) if @level >= INFO
  end

  def log(msg, type, obj = nil)
    @logger.log(msg, type, obj)
  end
end