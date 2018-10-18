class AddNameToUsers < ActiveRecord::Migration[5.2]
  def change
  end
  add_column :users, :name, :string
end
