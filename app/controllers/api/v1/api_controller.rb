module Api
  module V1
    class ApiController < ApplicationController
      before_filter :authenticate_user!
      respond_to :json

      def index
        rescue_find_by_user { respond_with(user_resources) }
      end

      def show
        rescue_find_by_user { respond_with(user_resource) } 
      end

      def create
        @resource = user_resources.new(resource_params)

        create_collaboratorship if creates_collaboratorship?

        if resource_created?
          render created
        else
          render unprocessable_entity
        end
      end

      def update
        rescue_find_by_user do 
          @resource = user_resources.find(params[:id])
          if @resource.update(resource_params)
            render :json => @resource, status: :accepted, location: resource_url(@resource)
          end
        end
      end

      def destroy
        @resource = user_resources.where(id: params[:id]).first

        if @resource && @resource.destroy
          render :json => {success: true,
                           message: "Resource successfully deleted.",
                           status: "204"}
        else
          render not_permitted
        end
      end

    private
      # Some call like:
      # 
      #   current_user.workspaces.find(params[:id])
      #
      # Will be passed in. If ActiveRecord::RecordNotFound is raised, then the resource may exist, but the current_user
      # may not be a collaborator on it. In that case, we check to see whether the resource exists at all. If it does,
      # we return 401 (Not Permitted), otherwise, we return 404 (Not Found).
      def rescue_find_by_user(&block)
        begin
          block.call
        rescue ActiveRecord::RecordNotFound
          render not_found and return unless not_permitted?
          rescue_find_by_user { raise NotPermitted }
        rescue NotPermitted
          render not_permitted and return
        end
      end

      def parent_resource_id_name
        params.keys.keep_if { |k| k.match(/\_id/) }.first
      end

      def parent_resource_id
        params[parent_resource_id_name]
      end

      def parent_resources_name
        parent_resource_id_name.gsub(/\_id/) { |n| "" }.pluralize.downcase
      end

      def parent_resource_name
        parent_resources_name.singularize
      end

      def parent_resource
        parent_resource_name.classify.constantize
      end

      def user_resource
        @resource = user_resources.where(id: params[:id]).first
        unless @resource
          resource.find(params[:id])
          raise NotPermitted 
        end
        @resource
      end

      def user_resources
        if parent_resource_id_name
          begin
            current_user.send(parent_resources_name).find(parent_resource_id)
              .send(resources_name)
          rescue
            raise NotPermitted
          end
        else
          current_user.send(resources_name)
        end
      end

      def resources_name
        self.class.name.gsub(/Api\:\:V1\:\:|Controller/) { |n| "" }.downcase
      end

      def resource_name
        resources_name.singularize
      end

      def resource
        resource_name.classify.constantize
      end

      def resource_params
        self.send("#{resource_name}_params")
      end

      def resource_url(resource)
        self.send("api_v1_#{resource_name}_url", resource)
      end

      def create_collaboratorship
        @collaboratorship = Collaboratorship.new(collaborator: current_user,
                                                 collaboratable: @resource,
                                                 role: "owner",
                                                 state: "active")
      end

      def creates_collaboratorship?
        collaboratable_resources.include?(resource_name.to_sym)
      end

      def collaboratable_resources
        [:project, :workspace]
      end

      def resource_created?
        return @resource.save && @collaboratorship.save if creates_collaboratorship?
        @resource.save
      end

      def not_permitted?
        resource.where(id: params[:id]).first
      end

      def not_permitted
        { :json => {success: false, 
                    error: "You don't have permission to view or modify that resource",
                    status:  "401"}, 
                    :status => "401" }
      end

      def not_found
        { :json => {success: false,
                    error: "Resource not found",
                    status: "404"}, status: :not_found }
      end

      def created
        { :json => @resource, status: :created, location: resource_url(@resource) }
      end

      def unprocessable_entity
        { :json => @resource.errors, status: :unprocessable_entity }
      end
    end
  end
end