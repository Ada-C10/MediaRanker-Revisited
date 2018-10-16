class AddOauthToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :uid, :integer, null: false
    add_column :users, :provider, :string, null: false
    add_column :users, :name, :string
  end
end
