namespace :anoubis do
  namespace :sessions do
    desc "Clear timeout sessions."

    task clear: [:environment] do
      service = Anoubis::SessionService.new
      service.clear
    end
  end
end