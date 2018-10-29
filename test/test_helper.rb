ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/skip_dsl"
require "minitest/reporters"  # for Colorized output

#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...


  def setup
    # Once you have enabled test mode, all requests
    # to OmniAuth will be short circuited to use the mock authentication hash.
    # A request to /auth/provider will redirect immediately to /auth/provider/callback.
    OmniAuth.config.test_mode = true
  end


  # Test helper method to generate a mock auth hash
  # for fixture data

  # turn an instance of class user into a fake auth-hash
  #why did we put this here?
  #we are only ever going to do this in the context of the test which is why its put here
  #and not in our public interface
  def mock_auth_hash(user)
    return {
      provider: user.provider,
      uid: user.uid,
      info: {
        email: user.email,
        name: user.username
      }
    }
  end

  def perform_login(user)
    #tell omniauth to use this user's info when it sees
    #an auth callback from github
    OmniAuth.config.mock_auth[:github] =
      OmniAuth::AuthHash.new(mock_auth_hash(user))

      #make the request to log in the user
    get auth_callback_path(:github)
  end
end
