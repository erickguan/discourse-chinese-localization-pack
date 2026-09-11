# name: Discourse 中文本地化服务集合
# about: 为 Discourse 增加了各种本地化的功能。
# version: 4.1.0
# authors: Erick Guan
# url: https://github.com/erickguan/discourse-chinese-localization-pack

enabled_site_setting :zh_l10n_enabled

gem("omniauth-weibo-oauth2", "0.5.3")

register_svg_icon "fab-weibo"
register_svg_icon "fab-qq"

# load oauth providers
Dir[File.expand_path("../lib/auth/*.rb", __FILE__)].each { |f| require f }
require "active_support/inflector"
require "ostruct"

PROVIDERS = ["Weibo"]

PLUGIN_PREFIX = "zh_l10n_".freeze
SITE_SETTING_NAME = "zh_l10n_enabled".freeze
ONEBOX_SETTING_NAME = "zh_l10n_http_onebox_override".freeze

def provider_icon(provider_name)
  provider_name = provider_name.downcase
  "fab-#{provider_name}"
end

PROVIDERS.each do |name|
  auth_provider(
    authenticator: "#{name}Authenticator".constantize.new,
    icon: provider_icon(name)
  )
end

Dir[File.expand_path("../lib/onebox_override/*.rb", __FILE__)].each do |f|
  require f
end

register_asset "stylesheets/buttons.scss"

after_initialize do
  next unless SiteSetting.zh_l10n_enabled

  Dir[File.expand_path("../lib/onebox/*.rb", __FILE__)].each { |f| require f }

  require_relative "app/services/problem_check/weibo_config"
  register_problem_check ProblemCheck::WeiboConfig

  DiscourseEvent.on(:site_setting_changed) do |site_setting|
    if site_setting.name == SITE_SETTING_NAME && site_setting.value_changed? &&
         site_setting.value == "f" # false
      PROVIDERS.each do |provider|
        SiteSetting.public_send(
          "#{PLUGIN_PREFIX}enable_#{provider[0].downcase}_logins=",
          false
        )
      end
    end
  end

  module ::DisableUsernameSuggester
    def to_client_hash
      hash = defined?(super) ? super : nil
      return nil unless hash

      # only catch when a oauth login and a username is random
      if hash[:auth_provider]
        match = (hash[:username] || "").match(/^\d+$/i)

        if SiteSetting.zh_l10n_disable_random_username_sugeestion && match
          hash[:username] = nil

          if SiteSetting.enable_names? &&
               SiteSetting.zh_l10n_disable_random_username_sugeestion && match
            hash[:name] = nil
          end
        end
      end

      hash
    end
  end

  Auth::Result.class_eval { prepend ::DisableUsernameSuggester }
end
