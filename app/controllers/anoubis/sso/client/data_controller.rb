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
class Anubis::Sso::Client::DataController < Anubis::Sso::Client::ApplicationController
  include Anubis::Sso::Client::Data::Actions
  include Anubis::Sso::Client::Data::Load
  include Anubis::Sso::Client::Data::Get
  include Anubis::Sso::Client::Data::Set
  include Anubis::Sso::Client::Data::Setup
  include Anubis::Sso::Client::Data::Defaults
  include Anubis::Sso::Client::Data::Convert
  include Anubis::Sso::Client::Data::Callbacks
end