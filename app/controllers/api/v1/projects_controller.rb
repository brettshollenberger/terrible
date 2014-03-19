module Api
  module V1
    class ProjectsController < ApiController
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

      def create
        begin
          @project = current_user.projects.new(project_params)
        rescue ActionController::ParameterMissing
          @project = current_user.projects.new
        end

        @collaboratorship = Collaboratorship.new(collaborator: current_user,
                                                 collaboratable: @project,
                                                 role: "owner",
                                                 state: "active")

        if @project.save && @collaboratorship.save
          render :json => @project, status: :created, location: api_v1_project_url(@project)
        else
          render :json => @project.errors, status: :unprocessable_entity
        end
      end

      def update
        begin
          @project = current_user.projects.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          begin
            @project = Project.find(params[:id])
          rescue ActiveRecord::RecordNotFound
            render :json => {success: false,
                             message: "Resource not found",
                             status: "404"}, status: :not_found and return
          end
          render :json => {success: false,
                           message: "You don't have permission to update that resource",
                           status: "401"}, status: :unauthorized and return
        end

        if @project.update(project_params)
          render :json => @project, status: :accepted, location: api_v1_project_url(@project)
        end
      end

    private
      def project_params
        params.require(:project).permit(:title, :description)
      end
    end
  end
end
