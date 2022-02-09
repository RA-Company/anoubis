require_dependency "anubis/core/application_controller"
require_dependency "anubis/core/data/actions"
require_dependency "anubis/core/data/load"
require_dependency "anubis/core/data/get"
require_dependency "anubis/core/data/set"
require_dependency "anubis/core/data/setup"
require_dependency "anubis/core/data/defaults"
require_dependency "anubis/core/data/convert"
require_dependency "anubis/core/data/callbacks"

module Anoubis
  ##
  # Module presents all core functions for Anubis Library
  module Core
    ##
    # Controller consists all procedures and function for presents and modify models data.
    class DataController < Anoubis::Core::ApplicationController
      include Anoubis::Core::Data::Actions
      include Anoubis::Core::Data::Load
      include Anoubis::Core::Data::Get
      include Anoubis::Core::Data::Set
      include Anoubis::Core::Data::Setup
      include Anoubis::Core::Data::Defaults
      include Anoubis::Core::Data::Convert
      include Anoubis::Core::Data::Callbacks
    end
  end
end
