class ChangeIntegerLimitForUid < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :uid, :integer, limit: 8
  end
end
