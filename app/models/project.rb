class Project < ActiveRecord::Base

  include Collaborations::Collaboratable

  after_initialize :defaults

  validates_presence_of :title

  has_many :collaboratorships,
    as: :collaboratable,
    dependent: :destroy

  has_many :users,
    through: :collaboratorships,
    source: :collaborator,
    source_type: "User"

  belongs_to :workspace

  def defaults
    unless self.title.length > 0
      self.title = "Untitled Project"
    end
  end

end
