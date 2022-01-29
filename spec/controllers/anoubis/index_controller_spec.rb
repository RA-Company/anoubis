require 'rails_helper'

module Anubis
  RSpec.describe IndexController, type: :controller do
    render_views

    context "when request sets accept => application/json" do
      it "should login" do
        request.accept = "application/json"
        post :login, params: { use_route: 'api/1', login: 'admin@local.local.sys', password: 'admin', version: 1 }
        user = JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 200
        expect(user[:result]).to eq 0
        expect(user.has_key? :message).to eq true
        expect(user.has_key? :token).to eq true
        expect(user.has_key? :name).to eq true
        expect(user.has_key? :surname).to eq true
        expect(user.has_key? :email).to eq true
      end

      it "has incorrect login" do
        request.accept = "application/json"
        post :login, params: { use_route: 'api/1', login: 'admin@local.local.sys', password: 'admin1', version: 1 }
        user = JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 422
        expect(user[:result]).to eq -2
        expect(user.has_key? :token).to eq false
        expect(user.has_key? :message).to eq true
      end

      it "has invalid login parameters" do
        request.accept = "application/json"
        post :login, params: { use_route: 'api/1', login: 'admin@local.local.sys', version: 1 }
        user = JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 422
        expect(user[:result]).to eq -1
        expect(user.has_key? :token).to eq false
      end

      it "can get menu for logged in user" do
        request.accept = "application/json"
        post :login, params: { use_route: 'api/1', login: 'admin@local.local.sys', password: 'admin', version: 1 }
        user = JSON.parse(response.body, { symbolize_names: true })
        request.headers['Authorization'] = 'Bearer '+user[:token]
        get :menu, params: { use_route: 'api/1', version: 1 }
        menu = JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 200
        expect(menu[:result]).to eq 0
        expect(menu.has_key? :menu).to eq true
      end

      it "can't get menu for unauthorized user" do
        request.accept = "application/json"
        get :menu, params: { use_route: 'api/1', version: 1 }
        JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 422
      end

      it "can logout" do
        request.accept = "application/json"
        post :login, params: { use_route: 'api/1', login: 'admin@local.local.sys', password: 'admin', version: 1 }
        data = JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 200
        expect(data[:result]).to eq 0
        user = JSON.parse(response.body, { symbolize_names: true })
        request.headers['Authorization'] = 'Bearer '+user[:token]
        get :logout, params: { use_route: 'api/1', version: 1 }
        data = JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 200
        expect(data[:result]).to eq 0
        get :menu, params: { use_route: 'api/1', version: 1 }
        JSON.parse(response.body, { symbolize_names: true })
        expect(response.status).to eq 422
      end
    end
  end
end
