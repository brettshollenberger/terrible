class User < ActiveRecord::Base
  include Collaborations::Collaboratorable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :first, :last

  has_many :collaboratorships,
    as: :collaborator,
    dependent: :destroy

  has_many :projects,
    through: :collaboratorships,
    source: :collaboratable,
    source_type: "Project"
end
