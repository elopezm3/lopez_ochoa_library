class Autor < ApplicationRecord
  has_many :libros, dependent: :destroy
  
  validates :apellido, presence: true
  
  def full_name
    "#{nombre} #{apellido}".strip
  end
  
  def apellido_y_nombre
    if nombre.present?
      "#{apellido} #{nombre}"
    else
      apellido
    end
  end
end
