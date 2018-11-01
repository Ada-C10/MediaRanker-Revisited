class ChangeUisToUidInUserTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :uis, :uid
  end
end
