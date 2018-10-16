module ApplicationHelper
  def render_date(date)
    date.strftime("%b %e, %Y")
  end

  def render_username
    id = session[:user_id]
    user = User.find_by(id: id)
    return user.username
  end
end
