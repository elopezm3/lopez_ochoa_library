class CreateAutors < ActiveRecord::Migration[7.2]
  def change
    create_table :autores do |t|
      t.string :nombre
      t.string :apellido

      t.timestamps
    end
  end
end
