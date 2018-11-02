class AddOauthColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column(:users, :name, :string)
    add_column(:users, :email, :string)
    add_column(:users, :uid, :integer, null: false) # this is the identifier provided by GitHub
    add_column(:users, :provider, :string, null: false) # this is the identifier provided by GitHub


  end
end
