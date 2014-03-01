class ChangeDefaultCollaboratorshipRoleToCollaborator < ActiveRecord::Migration
  def self.up
    change_column :collaboratorships, :role, :string, null: false, default: :collaborator
  end

  def self.down
    change_column :collaboratorships, :role, :string, null: false, default: :member
  end
end
