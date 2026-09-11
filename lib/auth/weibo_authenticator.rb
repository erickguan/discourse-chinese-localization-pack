class WeiboAuthenticator < ::Auth::ManagedAuthenticator
  def name
    'weibo'
  end

  def enable_setting
    :zh_l10n_enable_weibo_logins
  end

  def required_settings
    %i[zh_l10n_weibo_client_id zh_l10n_weibo_client_secret]
  end

  def match_by_email
    false
  end

  def can_revoke?
    true
  end

  def can_connect_existing_user?
    true
  end

  def register_middleware(omniauth)
    omniauth.provider :weibo, setup: lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.zh_l10n_weibo_client_id
      strategy.options[:client_secret] = SiteSetting.zh_l10n_weibo_client_secret
    }
  end
end
