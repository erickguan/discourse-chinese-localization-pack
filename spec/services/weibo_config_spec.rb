RSpec.describe ProblemCheck::WeiboConfig do
  subject(:check) { described_class.new }

  it "accepts disabled login" do
    expect(check).to be_chill_about_it
  end

  it "accepts configured login" do
    SiteSetting.zh_l10n_weibo_client_id = "client_id"
    SiteSetting.zh_l10n_weibo_client_secret = "client_secret"
    SiteSetting.zh_l10n_enable_weibo_logins = true

    expect(check).to be_chill_about_it
  end

  it "reports credentials cleared while login is enabled" do
    SiteSetting.zh_l10n_weibo_client_id = "client_id"
    SiteSetting.zh_l10n_weibo_client_secret = "client_secret"
    SiteSetting.zh_l10n_enable_weibo_logins = true
    SiteSetting.zh_l10n_weibo_client_secret = ""

    expect(check).to have_a_problem.with_message(
      "{{setting:zh_l10n_enable_weibo_logins}} is on, but {{setting:zh_l10n_weibo_client_secret}} must still be set."
    )
  end
end
