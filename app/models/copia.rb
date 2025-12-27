class Copia < ApplicationRecord
  belongs_to :libro
  
  def loaned?
    prestamo.present?
  end
  
  def return!
    update!(prestamo: nil, fecha: nil)
  end
  
  def loan!(borrower_name)
    update!(prestamo: borrower_name, fecha: Date.today)
  end
end

