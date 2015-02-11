module ApplicationHelper

  def get_selected(path)
    path == request.path ? 'btn-selected' : ''
  end

end
