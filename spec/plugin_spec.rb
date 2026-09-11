require "rails_helper"

load File.expand_path("../helpers.rb", __FILE__)

RSpec.configure { |config| config.include HTMLSpecHelper }

RSpec.describe Discourse do
  it "load all authenticators" do
    ["Weibo"].each do |provider_name|
      expect(
        Discourse.auth_providers.any? do |a|
          a.authenticator.class.name.demodulize ==
            "#{provider_name}Authenticator"
        end
      ).to be_truthy
    end
  end
end
