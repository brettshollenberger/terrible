class Project < ActiveRecord::Base
  validates_presence_of :title

  has_many :collaboratorships,
    as: :collaboratable,
    dependent: :destroy

  has_many :users,
    through: :collaboratorships,
    source: :collaborator,
    source_type: "User"

end
