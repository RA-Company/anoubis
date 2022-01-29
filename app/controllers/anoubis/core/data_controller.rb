require_dependency "anubis/core/application_controller"
require_dependency "anubis/core/data/actions"
require_dependency "anubis/core/data/load"
require_dependency "anubis/core/data/get"
require_dependency "anubis/core/data/set"
require_dependency "anubis/core/data/setup"
require_dependency "anubis/core/data/defaults"
require_dependency "anubis/core/data/convert"
require_dependency "anubis/core/data/callbacks"

module Anubis
  ##
  # Module presents all core functions for Anubis Library
  module Core
    ##
    # Controller consists all procedures and function for presents and modify models data.
    class DataController < Anubis::Core::ApplicationController
      include Anubis::Core::Data::Actions
      include Anubis::Core::Data::Load
      include Anubis::Core::Data::Get
      include Anubis::Core::Data::Set
      include Anubis::Core::Data::Setup
      include Anubis::Core::Data::Defaults
      include Anubis::Core::Data::Convert
      include Anubis::Core::Data::Callbacks
    end
  end
end
