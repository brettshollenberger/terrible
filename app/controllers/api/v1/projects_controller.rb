module Api
  module V1
    class ProjectsController < ApplicationController
      before_filter :authenticate_user!
      respond_to :json

      def index
        respond_with(current_user.projects)
      end

      def show
        @project = current_user.projects.where(id: params[:id]).first
        if @project
          respond_with(@project)
        else
          render :json => {success: false, 
                           message: "You don't have permission to view that resource"},
                           :status => "401"
        end
      end
    end
  end
end
