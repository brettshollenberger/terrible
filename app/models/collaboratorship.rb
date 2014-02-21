class Collaboratorship < ActiveRecord::Base
  validates_presence_of :collaboratable, :collaborator, :role, :state
  belongs_to :collaborator, polymorphic: true
  belongs_to :collaboratable, polymorphic: true
end
