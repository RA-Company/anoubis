require_dependency "anoubis/data/actions"
require_dependency "anoubis/data/load"
require_dependency "anoubis/data/get"
require_dependency "anoubis/data/set"
require_dependency "anoubis/data/setup"
require_dependency "anoubis/data/defaults"
require_dependency "anoubis/data/convert"
require_dependency "anoubis/data/callbacks"

##
# Main data controller class
class Anoubis::DataController < Anoubis::ApplicationController
  include Anoubis::Data::Actions
  include Anoubis::Data::Load
  include Anoubis::Data::Get
  include Anoubis::Data::Set
  include Anoubis::Data::Setup
  include Anoubis::Data::Defaults
  include Anoubis::Data::Convert
  include Anoubis::Data::Callbacks
end