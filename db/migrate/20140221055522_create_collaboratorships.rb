class CreateCollaboratorships < ActiveRecord::Migration
  def change
    create_table :collaboratorships do |t|
      t.integer :collaboratable_id, null: false
      t.string :collaboratable_type, null: false
      t.integer :collaborator_id, null: false
      t.string :collaborator_type, null: false, default: :user
      t.string :role, null: false, default: :member
      t.string :state, null: false, default: :pending

      t.timestamps
    end
  end
end
