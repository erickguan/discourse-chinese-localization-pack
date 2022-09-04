# name: Discourse 中文本地化服务集合
# about: 为 Discourse 增加了各种本地化的功能。
# version: 2.0.1
# authors: Erick Guan
# url: https://github.com/fantasticfears/discourse-chinese-localization-pack

enabled_site_setting :zh_l10n_enabled

gem('omniauth-douban-oauth2', '0.0.7') # https://github.com/liluo/omniauth-douban-oauth2
gem('omniauth-qq', '0.3.0') # https://github.com/beenhero/omniauth-qq
gem('omniauth-weibo-oauth2', '0.5.2') # https://github.com/beenhero/omniauth-weibo-oauth2

register_svg_icon 'fab-weibo'
register_svg_icon 'fab-qq'
# register_svg_icon 'zhl10n-douban'

# load oauth providers
Dir[File.expand_path('../lib/auth/*.rb', __FILE__)].each { |f| require f }
require 'active_support/inflector'
require "ostruct"

PROVIDERS = ['Weibo', 'QQ', 'Douban']

PLUGIN_PREFIX = 'zh_l10n_'.freeze
SITE_SETTING_NAME = 'zh_l10n_enabled'.freeze
ONEBOX_SETTING_NAME = 'zh_l10n_http_onebox_override'.freeze

def provider_icon(provider_name)
  provider_name = provider_name.downcase
  if provider_name == "douban"
    nil
  else
    "fab-#{provider_name}"
  end
end

PROVIDERS.each { |name| auth_provider(authenticator: "#{name}Authenticator".constantize.new, icon: provider_icon(name)) }

Dir[File.expand_path('../lib/onebox_override/*.rb', __FILE__)].each { |f| require f }

register_asset "stylesheets/buttons.scss"

after_initialize do
  next unless SiteSetting.zh_l10n_enabled

  Dir[File.expand_path('../lib/onebox/*.rb', __FILE__)].each { |f| require f }

  PROVIDERS.each do |name|
    provider_name = name.downcase
    enable_setting = "#{PLUGIN_PREFIX}enable_#{provider_name}_logins"
    check = "#{provider_name}_config_check".to_sym

    AdminDashboardData.class_eval do
      define_method(check) do
        if SiteSetting.public_send(enable_setting) && (
            SiteSetting.public_send("#{PLUGIN_PREFIX}#{provider_name}_client_id").blank? ||
            SiteSetting.public_send("#{PLUGIN_PREFIX}#{provider_name}_client_secret").blank?)
          I18n.t("dashboard.#{PLUGIN_PREFIX}#{provider_name}_config_warning")
        end
      end
    end
    AdminDashboardData.add_problem_check check
  end

  DiscourseEvent.on(:site_setting_changed) do |site_setting|
    if site_setting.name == SITE_SETTING_NAME && site_setting.value_changed? && site_setting.value == "f" # false
      PROVIDERS.each { |provider| SiteSetting.public_send("#{PLUGIN_PREFIX}enable_#{provider[0].downcase}_logins=", false) }
    end
  end

  module ::DisableUsernameSuggester
    def to_client_hash
      hash = defined?(super) ? super : nil
      return nil unless hash

      # only catch when a oauth login and a username is random
      if hash[:auth_provider]
        match = (hash[:username] || '').match(/^\d+$/i)

        if SiteSetting.zh_l10n_disable_random_username_sugeestion && match
          hash[:username] = nil

          if SiteSetting.enable_names? && SiteSetting.zh_l10n_disable_random_username_sugeestion && match
            hash[:name] = nil
          end
        end
      end

      hash
    end
  end

  Auth::Result.class_eval do
    prepend ::DisableUsernameSuggester
  end
end
