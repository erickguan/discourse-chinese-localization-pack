class ProblemCheck::WeiboConfig < ProblemCheck::AuthProviderConfig
  private

  def authenticator
    @authenticator ||= WeiboAuthenticator.new
  end
end
