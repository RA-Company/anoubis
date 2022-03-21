require_dependency "anoubis/tenant/application_controller"
require_dependency "anoubis/tenant/data/actions"
require_dependency "anoubis/tenant/data/load"
require_dependency "anoubis/tenant/data/get"
require_dependency "anoubis/tenant/data/set"
require_dependency "anoubis/tenant/data/setup"
require_dependency "anoubis/tenant/data/defaults"
require_dependency "anoubis/tenant/data/convert"
require_dependency "anoubis/tenant/data/callbacks"

module Anoubis
  ##
  # Module presents all core functions for Anubis Library
  module Tenant
    ##
    # Controller consists all procedures and function for presents and modify models data.
    class DataController < Anoubis::Tenant::ApplicationController
      include Anoubis::Tenant::Data::Actions
      include Anoubis::Tenant::Data::Load
      include Anoubis::Tenant::Data::Get
      include Anoubis::Tenant::Data::Set
      include Anoubis::Tenant::Data::Setup
      include Anoubis::Tenant::Data::Defaults
      include Anoubis::Tenant::Data::Convert
      include Anoubis::Tenant::Data::Callbacks
    end
  end
end