class AddColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :vote, :string
  end
end
