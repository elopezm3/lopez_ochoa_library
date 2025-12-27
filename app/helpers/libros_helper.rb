module LibrosHelper
  def sortable_column(column, title, current_sort, current_direction)
    direction = if current_sort == column && current_direction == 'asc'
                  'desc'
                else
                  'asc'
                end
    
    link_class = "hover:text-amber-700 cursor-pointer"
    if current_sort == column
      link_class += " font-bold text-amber-800"
      arrow = current_direction == 'asc' ? ' ↑' : ' ↓'
    else
      arrow = ''
    end
    
    link_to(
      "#{title}#{arrow}".html_safe,
      libros_path(sort: column, direction: direction, buscar: params[:buscar]),
      class: link_class
    )
  end
end
