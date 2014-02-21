module Collaborations
  module Collaboratorable
    def collaboratables(type)
      Collaboratorship.where(collaborator: self, collaboratable_type: type.to_s.classify)
    end
  end
end
