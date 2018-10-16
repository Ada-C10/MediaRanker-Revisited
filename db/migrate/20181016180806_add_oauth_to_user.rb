class AddOauthToUser < ActiveRecord::Migration[5.2]
  def change

    rename_column :users, :name, :name
    add_column :users, :email, :string
    add_column :users, :uid, :integer, null: false
    add_column :users, :provider, :string, null: false

  end
end
