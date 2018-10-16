class AddOathColumnsToUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email, :string
    add_column :users, :uis, :integer,  null: false
    add_column :users, :provider, :string, null: false
  end
end
