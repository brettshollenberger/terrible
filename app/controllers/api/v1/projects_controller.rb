module Api
  module V1
    class ProjectsController < ApplicationController
      before_filter :authenticate_user!
      respond_to :json

      def index
        respond_with(Project.all)
      end
    end
  end
end
