module Api
  module V1
    class WorkspacesController < ApiController

    private
      def workspace_params
        params.require(:workspace).permit(:name)
      end

      def queryable_keys
        [:name]
      end
    end
  end
end
