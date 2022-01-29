require_dependency "anubis/tenant/application_controller"
require_dependency "anubis/tenant/data/actions"
require_dependency "anubis/tenant/data/load"
require_dependency "anubis/tenant/data/get"
require_dependency "anubis/tenant/data/set"
require_dependency "anubis/tenant/data/setup"
require_dependency "anubis/tenant/data/defaults"
require_dependency "anubis/tenant/data/convert"
require_dependency "anubis/tenant/data/callbacks"

module Anubis
  ##
  # Module presents all core functions for Anubis Library
  module Tenant
    ##
    # Controller consists all procedures and function for presents and modify models data.
    class DataController < Anubis::Tenant::ApplicationController
      include Anubis::Tenant::Data::Actions
      include Anubis::Tenant::Data::Load
      include Anubis::Tenant::Data::Get
      include Anubis::Tenant::Data::Set
      include Anubis::Tenant::Data::Setup
      include Anubis::Tenant::Data::Defaults
      include Anubis::Tenant::Data::Convert
      include Anubis::Tenant::Data::Callbacks
    end
  end
end