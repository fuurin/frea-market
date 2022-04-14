# frozen_string_literal: true

module RequestMacros
  def authorized_headers(user = nil, version = 1)
    user ||= FactoryBot.create(:user)
    post send("v#{version}_user_session_path"),
         params: { email: user.email, password: user.password }
    response.headers.select { |k, _v| %w[access-token client uid].include?(k) }
  end
end
