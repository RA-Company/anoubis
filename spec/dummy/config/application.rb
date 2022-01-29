require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "anoubis"

module Dummy
  class Application < Rails::Application
    config.load_defaults 5.2
    config.api_only = true
  end
end

