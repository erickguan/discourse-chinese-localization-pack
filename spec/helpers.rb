require "rspec"
require "pry"
require "onebox"
require "mocha/api"

module HTMLSpecHelper
  def fake(uri, response, verb = :get)
    stub_request(verb, uri).to_return(body: response)
  end

  def header(html)
    "HTTP/1.1 200 OK\n\n#{html}"
  end

  def onebox_view(html)
    %|<div class="onebox">#{html}</div>|
  end

  def response(file)
    file = File.expand_path("fixtures/#{file}.response", __dir__)
    File.exist?(file) ? File.read(file) : ""
  end
end

module PluginSpecHelpers
  def load_auth_hash(name)
    YAML.load_file(
      File.expand_path("../fixtures/oauth_tokens.yml", __FILE__),
      permitted_classes: [Symbol, Date]
    )[
      name
    ]
  end
end
