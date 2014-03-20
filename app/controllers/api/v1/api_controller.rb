module Api
  module V1
    class ApiController < ApplicationController
      before_filter :authenticate_user!
      respond_to :json

      # Without any query params, the index action returns all resources for a given user.
      #
      # The index action also allows several types of queries into the database:
      # 
      # Exact queries:
      #   /projects?title=The Best Project&description=Very good
      #
      # This query will return any projects that match the search parameters exactly.
      #
      # Fuzzy searches:
      #   /projects?title=project&fuzzy=true
      #
      # This query will return any projects that contain the word "project" in the title. An AJAX search bar might employ
      # this type of query. This query is case-insensitive, and would match:
      #
      #   Project 1
      #   The Best PROJECT
      #   project morpheus
      #
      # Etc.
      #
      # Searches across any queryable attribute:
      #   /projects?any=project&fuzzy=true
      # 
      # This query will return any project that contains the word "project" in the title or description (assuming title
      # and description are the queryable attributes). Queryable attributes should be defined in each model's controller
      # in order to provide this behavior.
      #
      # Search bars may also provide this functionality to allow a user to find exactly what they're looking for without
      # searching the correct field. This action can potentially be resource intensive.
      #
      # ###############################################################################################################
      def index
        rescue_401_or_404 { respond_with(user_resources.where(build_query)) }
      end

      def show
        rescue_401_or_404 { respond_with(user_resource) } 
      end

      def create
        @resource = user_resources.new(resource_params)
        create_collaboratorship if creates_collaboratorship?
        render resource_created? ? created : unprocessable_entity
      end

      def update
        rescue_401_or_404 do 
          @resource = user_resources.find(params[:id])
          render resource_updated? ? updated : unprocessable_entity
        end
      end

      def destroy
        rescue_401_or_404 do
          @resource = user_resources.find(params[:id])
          render resource_deleted? ? deleted : not_permitted
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
      # ###############################################################################################################
      def rescue_401_or_404(&block)
        begin
          block.call
        rescue ActiveRecord::RecordNotFound
          render not_found and return unless not_permitted?
          rescue_401_or_404 { raise NotPermitted }
        rescue NotPermitted
          render not_permitted and return
        end
      end

      def build_query
        query = [""]
        queryable_entity.each do |key, value|
          add_sql_statement(query, key, value) if queryable?(key)
        end
        query
      end

      def queryable_entity
        params[:any] ? queryable_keys : params
      end

      def add_sql_statement(query, key, value)
        compound_sql_statement(query)
        add_sql_condition(query, key)
        add_sql_predicate(query, value)
      end

      def queryable?(key)
        queryable_keys.include?(key.to_sym)
      end

      def compound_sql_statement(query)
        query[0] += (params[:any] ? " OR " : " AND ") if query[0].length > 0
      end

      def add_sql_condition(query, key)
        query[0] += (fuzzy? ? "#{key} ILIKE ?" : "#{key} = ?")
      end

      def add_sql_predicate(query, value)
        query.push(params[:any] ? build_search_term(params[:any]) : build_search_term(value))
      end

      def build_search_term(value)
        fuzzy? ? "%#{value}%" : value
      end

      def fuzzy?
        params[:fuzzy] != nil && params[:fuzzy].to_s != "false"
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
        creates_collaboratorship? ? @resource.save && @collaboratorship.save : @resource.save
      end

      def resource_updated?
        @resource.update(resource_params)
      end

      def resource_deleted?
        @resource.destroy
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

      def updated
        { :json => @resource, status: :accepted, location: resource_url(@resource) }
      end

      def deleted
        { :json => {success: true,
                    message: "Resource successfully deleted.",
                    status: "204"} }
      end

      def unprocessable_entity
        { :json => @resource.errors, status: :unprocessable_entity }
      end
    end
  end
end
