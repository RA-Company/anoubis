module Anoubis
  ##
  # Default mailer for Anoubis library
  class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
  end
end
