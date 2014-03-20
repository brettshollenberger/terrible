module Api
  module V1
    class ProjectsController < ApiController

    private
      def project_params
        params.require(:project).permit(:title, :description)
      end

      def queryable_keys
        [:title, :description]
      end
    end
  end
end
