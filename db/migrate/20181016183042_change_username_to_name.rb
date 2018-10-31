class ChangeuserToName < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :user, :string
    add_column :users, :name, :string
  end
end
