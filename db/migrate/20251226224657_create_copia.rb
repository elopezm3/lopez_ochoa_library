class CreateCopia < ActiveRecord::Migration[7.2]
  def change
    create_table :copias do |t|
      t.references :libro, null: false, foreign_key: true
      t.string :prestamo
      t.date :fecha

      t.timestamps
    end
  end
end
