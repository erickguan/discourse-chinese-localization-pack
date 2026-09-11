require "rails_helper"
require_relative "../../../lib/onebox/engine/cloudmusic"
load File.expand_path("../../../helpers.rb", __FILE__)

describe Onebox::Engine::CloudMusicOnebox do
  include HTMLSpecHelper

  before do
    stub_request(:get, "http://music.163.com/#/song?id=691506").to_return(
      body: response("cloudmusic"),
      headers: {
        "Content-Type" => "text/html"
      }
    )
  end

  it "returns object as the placeholder" do
    expect(
      Onebox.preview("http://music.163.com/#/song?id=691506").placeholder_html
    ).to match(/iframe/)
  end
end
