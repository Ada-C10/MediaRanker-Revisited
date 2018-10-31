class AddUsernameColumnToUserTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :username, :string
  end
end
