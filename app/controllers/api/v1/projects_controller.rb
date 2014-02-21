module Api
  module V1
    class ProjectsController < ApplicationController
      before_filter :authenticate_user!
      respond_to :json

      def index
        respond_with(current_user.projects)
      end
    end
  end
end
