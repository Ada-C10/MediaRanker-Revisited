class ChangeIntegerLimitInYourTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :uid
    add_column :users, :uid, :integer, limit: 8
  end
end
