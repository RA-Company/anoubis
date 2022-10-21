class Anoubis::Logger::Console
  def log(msg, type, obj = nil)
    time = Time.now
    case type
    when Anoubis::Logger::App::CRITICAL
      type = 'CRT'
    when Anoubis::Logger::App::ERROR
      type = 'ERR'
    when Anoubis::Logger::App::WARNING
      type = 'WRN'
    when Anoubis::Logger::App::INFO
      type = 'INF'
    end
    if obj
      puts "#{time.strftime('%Y-%m-%d %H:%M:%S.%L')}\t#{type}\t#{msg}\t#{obj}"
    else
      puts "#{time.strftime('%Y-%m-%d %H:%M:%S.%L')}\t#{type}\t#{msg}"
    end
  end
end