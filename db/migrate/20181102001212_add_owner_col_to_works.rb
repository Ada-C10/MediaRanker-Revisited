class AddOwnerColToWorks < ActiveRecord::Migration[5.2]
  def change
    add_column :works, :owner, :string
  end
end
