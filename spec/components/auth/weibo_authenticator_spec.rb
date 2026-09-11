require_relative "../../helpers"

RSpec.describe WeiboAuthenticator do
  include PluginSpecHelpers

  subject(:authenticator) { described_class.new }

  fab!(:user)
  let(:auth_hash) { load_auth_hash("weibo") }
  let(:association) do
    UserAssociatedAccount.find_by!(
      provider_name: "weibo",
      provider_uid: auth_hash[:uid]
    )
  end

  describe "#after_authenticate" do
    it "authenticates an existing associated user" do
      Fabricate(
        :user_associated_account,
        provider_name: "weibo",
        provider_uid: auth_hash[:uid],
        user: user
      )

      expect(authenticator.after_authenticate(auth_hash).user).to eq(user)
    end

    it "stores provider information" do
      authenticator.after_authenticate(auth_hash)

      expect(association.extra["raw_info"]).to eq(
        auth_hash[:extra][:raw_info].stringify_keys
      )
    end

    it "returns a result for an unassociated account" do
      result = authenticator.after_authenticate(auth_hash)

      expect(result.user).to be_nil
      expect(result.extra_data).to eq(provider: "weibo", uid: auth_hash[:uid])
    end
  end

  describe "#after_create_account" do
    it "links an existing association without losing provider information" do
      result = authenticator.after_authenticate(auth_hash)

      authenticator.after_create_account(user, result)

      expect(association.user).to eq(user)
      expect(association.extra["raw_info"]).to eq(
        auth_hash[:extra][:raw_info].stringify_keys
      )
    end

    it "creates a missing association" do
      result = Auth::Result.new
      result.extra_data = { provider: "weibo", uid: auth_hash[:uid] }

      authenticator.after_create_account(user, result)

      expect(association.user).to eq(user)
    end
  end
end
