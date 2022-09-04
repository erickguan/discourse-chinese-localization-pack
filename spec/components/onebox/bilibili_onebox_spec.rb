require 'spec_helper'
load File.expand_path('../../../helpers.rb', __FILE__)

describe Onebox::Engine::BilibiliOnebox do
  before do
    FakeWeb.register_uri(:get, 'http://www.bilibili.com/video/av4235068/', body: response('bilibili'), content_type: 'text/html')
    FakeWeb.register_uri(:get, 'https://www.bilibili.com/video/BV1Zt4y1E7mU?spm_id_from=333.1007.tianma.1-1-1.click', body: response('bilibili'), content_type: 'text/html')
  end

  it 'returns object as the placeholder' do
    expect(Onebox.preview('http://www.bilibili.com/video/av4235068/')
        .placeholder_html).to match(/iframe/)
  end
  
  it 'returns bv object as the placeholder' do
    expect(Onebox.preview('https://www.bilibili.com/video/BV1Zt4y1E7mU?spm_id_from=333.1007.tianma.1-1-1.click')
        .placeholder_html).to match(/iframe/)
  end
end
