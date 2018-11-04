class RemoveForeignKey < ActiveRecord::Migration[5.2]
  def change
    remove_column :works, :user_id
  end
end
