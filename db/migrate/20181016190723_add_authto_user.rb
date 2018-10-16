class AddAuthtoUser < ActiveRecord::Migration[5.2]
  def change
    # Rails loves both symbols and implicit parens
    add_column :users, :name, :string
    add_column :users, :email, :string
    add_column :users, :uid, :integer, null:false
    # this is the identifier provided by GitHub
    add_column :users, :provider, :string, null:false
    # this tells us who provided the identifier
  end
end
