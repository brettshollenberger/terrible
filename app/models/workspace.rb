class Workspace < ActiveRecord::Base

  has_many :users,
    through: :collaboratorships,
    source: :collaborator,
    source_type: "User"

end
