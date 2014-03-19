module Api
  module V1
    class ApiController < ApplicationController
      before_filter :authenticate_user!
      respond_to :json

      def index
        respond_with(user_resources)
      end

      def show
        @resource = user_resources.where(id: params[:id]).first
        if @resource
          respond_with(@resource)
        else
          render :json => {success: false, 
                           message: "You don't have permission to view that resource"},
                           :status => "401"
        end
      end

      def create
        begin
          @resource = current_user.send(resources_name).new(resource_params)
        rescue ActionController::ParameterMissing
          @resource = user_resources.new
        end

        @collaboratorship = Collaboratorship.new(collaborator: current_user,
                                                 collaboratable: @resource,
                                                 role: "owner",
                                                 state: "active")

        if @resource.save && @collaboratorship.save
          render :json => @resource, status: :created, location: resource_url(@resource)
        else
          render :json => @resource.errors, status: :unprocessable_entity
        end
      end

      def update
        begin
          @resource = user_resources.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          begin
            @resource = resource.find(params[:id])
          rescue ActiveRecord::RecordNotFound
            render :json => {success: false,
                             message: "Resource not found",
                             status: "404"}, status: :not_found and return
          end
          render :json => {success: false,
                           message: "You don't have permission to update that resource",
                           status: "401"}, status: :unauthorized and return
        end

        if @resource.update(resource_params)
          render :json => @resource, status: :accepted, location: resource_url(@resource)
        end
      end

    private
      def user_resources
        current_user.send(resources_name)
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
    end
  end
end
