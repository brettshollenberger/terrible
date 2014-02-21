class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title, null: false, default: "Untitled Project"
      t.string :description

      t.timestamps
    end
  end
end
