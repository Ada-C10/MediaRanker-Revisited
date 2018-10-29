class RemoveNullInUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :uid, true
    change_column_null :users, :provider, true
  end
end
