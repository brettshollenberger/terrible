module Api
  module V1
    class ProjectsController < ApplicationController
      before_filter :authenticate_user!
      respond_to :json

      def index
        @projects = current_user.collaboratables(:project)
        respond_with(@projects)
      end
    end
  end
end
