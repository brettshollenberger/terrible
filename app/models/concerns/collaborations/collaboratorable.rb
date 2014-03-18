module Collaborations
  module Collaboratorable
    def collaboratorship_for(collaboratable)
      Collaboratorship.where(collaboratable: collaboratable, 
                             collaborator: self).first
    end

    def active_collaboratorships
      Collaboratorship.where(collaborator: self, state: "active")
    end

    def pending_collaboratorships
      Collaboratorship.where(collaborator: self, state: "pending")
    end

    def role_for(collaboratable)
      collaboratorship_for(collaboratable).role
    end

    def state_for(collaboratable)
      collaboratorship_for(collaboratable).state
    end

  private

    # class MissingMethod
    # 
    # The MissingMethod class helps us to find missing methods. Since the method_missing
    # method is particularly cumbersome with the number of generic methods the Collaboratorable
    # concern can support, we're delegating to this class to simplify our code.
    #
    # We may be asking whether a collaborator contains a certain role for a given
    # collaboratable, like:
    #
    #     current_user.owner?(@project)
    #     current_user.collaborator?(@team)
    #
    # We may also be asking for a collaborator's collaboratables of a given state, like:
    #
    #     current_user.active_projects
    #     current_user.pending_teams
    #
    # To find a missing method, we call MissingMethod.new.find
    class MissingMethod
      attr_accessor :method_name, :collaborator, :args

      def initialize(method_name, collaborator, args)
        @method_name  = method_name.to_s
        @collaborator = collaborator
        @args         = args
      end

      def find
        return role?           if interrogating_role?
        return collaboratables if looking_for_collaboratables?
      end

    private
      def interrogating_role?
        @method_name[-1] == '?' && @args.length == 1
      end

      def role?
        @collaborator.role_for(@args[0]) == @method_name[0..-2] && 
          @collaborator.state_for(@args[0]) == "active"
      end

      def looking_for_collaboratables?
        method_name_starts_with_state
      end

      # E.g. active_teams calls blank_state_blank_collaboratable("active", "teams")
      def collaboratables
        blank_state_blank_collaboratable(method_pieces[0], 
                                         method_pieces[1])
      end

      def states
        ["active", "pending"]
      end

      def method_name_starts_with_state
        method_name_contains_underscore && 
          states.include?(method_pieces[0])
      end

      def method_pieces
        @method_name.split(/\_/)
      end

      def method_name_contains_underscore
        method_pieces.length > 1
      end

      # E.g. active_teams returns an array of Teams, not Collaboratorships
      def blank_state_blank_collaboratable(state, collaboratable)
        type = collaboratable.classify
        Collaboratorship.where(collaborator: @collaborator, 
                               state: state, 
                               collaboratable_type: type)
                                .map { |collaboratorship| collaboratorship.collaboratable }
      end
    end

    def method_missing(method_name, *arguments)
      @missing_method = MissingMethod.new(method_name, self, arguments)
      return @missing_method.find unless @missing_method.find.nil?
      super
    end
  end
end
