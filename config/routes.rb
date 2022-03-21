Anoubis::Engine.routes.draw do
  Rails.application.routes.draw do
    begin
      lib_type = Rails.configuration.anubis_type
    rescue
      lib_type = 'tenant'
    end


    if lib_type == 'tenant'
      match 'api/:version/*path', { controller: 'anoubis/tenant/index', action: 'options', constraints: { method: 'OPTIONS' }, via: [:options] }

      post  'api/:version/login', to: 'anoubis/tenant/index#login', :defaults => { :format => 'json' }
      post  'api/:version/validate', to: 'anoubis/tenant/index#validate', :defaults => { :format => 'json' }
      post  'api/:version/recover', to: 'anoubis/tenant/index#recover', :defaults => { :format => 'json' }
      post   'api/:version/logout', to: 'anoubis/tenant/index#logout', :defaults => { :format => 'json' }
      get   'api/:version/menu', to: 'anoubis/tenant/index#menu', :defaults => { :format => 'json' }

      scope path: 'api', :defaults => { :format => 'json' } do
        scope path: ':version' do
          namespace :anubis do
            get 'users', to: 'structure#index', as: 'structure_list'
            get 'users/frame', to: 'structure#frame', as: 'structure_frame'

            resources :tenants do
              collection do
                get :frame
              end
            end
          end
        end
      end
    end

    if lib_type == 'sso-server'
      scope path: 'api', defaults: { format: 'json' } do
        scope path: ':version' do
          match '*path', { controller: 'anoubis/sso/server/login', action: 'options', constraints: { method: 'OPTIONS' }, via: [:options] }

          get 'login', to: 'anoubis/sso/server/login#index'
          post 'login', to: 'anoubis/sso/server/login#create'
          get 'login/:session', to: 'anoubis/sso/server/login#show'
          put 'login/:session', to: 'anoubis/sso/server/login#update'
          delete 'login/:session', to: 'anoubis/sso/server/login#destroy'

          get 'user/current', to: 'anoubis/sso/server/user#show_current'
          get 'user/:uuid', to: 'anoubis/sso/server/user#show'
          put 'user/current', to: 'anoubis/sso/server/user#update_current'
          put 'user/:uuid', to: 'anoubis/sso/server/user#update'
        end
      end
    end

    if lib_type == 'sso-client'
      scope path: 'api', defaults: { format: 'json' } do
        scope path: ':version' do
          match '*path', { controller: 'anoubis/sso/server/login', action: 'options', constraints: { method: 'OPTIONS' }, via: [:options] }

          get 'menu', to: 'anoubis/sso/client/index#menu'
          post 'logout', to: 'anoubis/sso/client/index#logout'
          #get 'login', to: 'anubis/sso/server/login#index'
          #post 'login', to: 'anubis/sso/server/login#create'
          #put 'login/:session', to: 'anubis/sso/server/login#update'
          #delete 'login/:session', to: 'anubis/sso/server/login#destroy'

          #get 'user/current', to: 'anubis/sso/server/user#show_current'
          #get 'user/:uuid', to: 'anubis/sso/server/user#show'
          #put 'user/current', to: 'anubis/sso/server/user#update_current'
          #put 'user/:uuid', to: 'anubis/sso/server/user#update'
        end
      end
    end
  end
end
