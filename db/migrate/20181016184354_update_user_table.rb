class UpdateUserTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email, :string
    add_column :users, :uid, :integer,  null: false
  end
end
