# frozen_string_literal: true

RSpec.describe WeiboAuthenticator do
  subject(:authenticator) { described_class.new }

  before do
    SiteSetting.zh_l10n_weibo_client_id = "client_id"
    SiteSetting.zh_l10n_weibo_client_secret = "client_secret"
  end

  it "requires the login toggle" do
    expect(authenticator.enabled?).to eq(false)

    SiteSetting.zh_l10n_enable_weibo_logins = true
    expect(authenticator.enabled?).to eq(true)
  end

  %i[zh_l10n_weibo_client_id zh_l10n_weibo_client_secret].each do |setting|
    it "disables login when #{setting} is cleared" do
      SiteSetting.zh_l10n_enable_weibo_logins = true
      SiteSetting.public_send("#{setting}=", "")

      expect(authenticator.enabled?).to eq(false)
    end

    it "rejects enabling login without #{setting}" do
      SiteSetting.public_send("#{setting}=", "")

      expect { SiteSetting.zh_l10n_enable_weibo_logins = true }.to raise_error(
        Discourse::InvalidParameters
      )
    end
  end
end
