Rails.application.routes.draw do
  root "inicio#index"
  
  resources :autores
  resources :libros
  resources :copias do
    member do
      patch :loan
      patch :return
    end
  end
end
