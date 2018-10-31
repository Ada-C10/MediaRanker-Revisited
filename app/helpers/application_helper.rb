module ApplicationHelper
  def render_date(date)
    date.strftime("%b %e, %Y")
  end

  def logged_in?
    return false if session[:id] == nil

      current_user = User.find_by(id: session[:id], uid: @auth_hash[:uid], provider: @auth_hash[:provider])

      return current_user ? true : false
  end
end
