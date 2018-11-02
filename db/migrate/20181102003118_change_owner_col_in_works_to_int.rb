class ChangeOwnerColInWorksToInt < ActiveRecord::Migration[5.2]
  def change
    change_column :works, :owner, 'integer USING CAST(owner AS integer)'

  end
end
