module ApplicationHelper
  def render_date(date)
    date.strftime("%b %e, %Y")
  end

  def render_username
    id = session[:user_id]
    user = User.find_by(id: id)
    return user.username
  end

  def log_in_out_link
    if @login_user
      return link_to 'Log out', logout_path, method: :delete, class: 'btn btn-primary'
    else
      return link_to 'Log in with Github', 'auth/github', class: 'btn btn-primary'
    end
  end
end
