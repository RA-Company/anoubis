require_dependency "anubis/sso/client/application_controller"
require_dependency "anubis/sso/client/data/actions"
require_dependency "anubis/sso/client/data/load"
require_dependency "anubis/sso/client/data/get"
require_dependency "anubis/sso/client/data/set"
require_dependency "anubis/sso/client/data/setup"
require_dependency "anubis/sso/client/data/defaults"
require_dependency "anubis/sso/client/data/convert"
require_dependency "anubis/sso/client/data/callbacks"

# Controller consists all procedures and function for presents and modify models data.
class Anoubis::Sso::Client::DataController < Anoubis::Sso::Client::ApplicationController
  include Anoubis::Sso::Client::Data::Actions
  include Anoubis::Sso::Client::Data::Load
  include Anoubis::Sso::Client::Data::Get
  include Anoubis::Sso::Client::Data::Set
  include Anoubis::Sso::Client::Data::Setup
  include Anoubis::Sso::Client::Data::Defaults
  include Anoubis::Sso::Client::Data::Convert
  include Anoubis::Sso::Client::Data::Callbacks
end