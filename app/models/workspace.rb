class Workspace < ActiveRecord::Base

  validates_presence_of :name

  has_many :collaboratorships,
    as: :collaboratable,
    dependent: :destroy

  has_many :users,
    through: :collaboratorships,
    source: :collaborator,
    source_type: "User"

  has_many :projects

end
