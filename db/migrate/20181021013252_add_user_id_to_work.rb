class AddUserIdToWork < ActiveRecord::Migration[5.2]
  def change
    add_column :works, :user_id, :integer
  end
end
