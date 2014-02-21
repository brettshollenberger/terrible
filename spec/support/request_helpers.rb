include Warden::Test::Helpers

module Requests
  module JsonHelpers
    def user
      FactoryGirl.create(:user)
    end

    def login(user)
      login_as user, scope: :user
    end

    def current_user
      User.find(request.session[:user])
    end

    def json
      @json ||= JSON.parse(response.body)
    end
  end
end
