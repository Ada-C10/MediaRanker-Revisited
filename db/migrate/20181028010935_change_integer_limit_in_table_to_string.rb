class ChangeIntegerLimitInTableToString < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :uid
    add_column :users, :uid, :string
  end
end
