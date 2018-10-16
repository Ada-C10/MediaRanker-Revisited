class OathStuff < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :name
      t.string :email
      t.integer :uid, null: false # this is the identifier provided by GitHub
      t.string :provider, null: false # this tells us who provided the identifier

      # t.timestamps
    end
  end
end
