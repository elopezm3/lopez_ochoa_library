class Libro < ApplicationRecord
  belongs_to :autor
  has_many :copias, dependent: :destroy
  
  validates :titulo, presence: true
  
  attr_accessor :skip_copy_creation
  
  after_create :create_initial_copy, unless: :skip_copy_creation
  
  private
  
  def create_initial_copy
    copias.create!
  end
end
