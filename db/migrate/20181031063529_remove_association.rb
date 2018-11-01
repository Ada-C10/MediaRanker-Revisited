class RemoveAssociation < ActiveRecord::Migration[5.2]
  def change
    remove_reference :works, :user, foreign_key: true
  end
end
