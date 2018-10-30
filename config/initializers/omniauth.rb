Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], scope: "user:email"
  # provider :github,
  #   ENV.fetch("GITHUB_CLIENT_ID"),
  #   ENV.fetch("GITHUB_CLIENT_SECRET"),
  #   scope: "user:email"
end
