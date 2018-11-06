class AddOmniauthColumnsToUserModels < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email, :string
    add_column :users, :provider, :string
    add_column :users, :uid, :integer, null: false
  end
end
