require 'spec_helper'

describe OpenAuth2::Client do
  let(:config) do
    OpenAuth2::Config.new do |c|
      c.provider = OpenAuth2::Provider::Facebook
      c.access_token = :access_token
    end
  end

  subject {described_class.new(config)}

  context '#initialize' do
    it 'accepts config as an argument' do
      subject.config.should == config
    end
  end

  context OpenAuth2::DelegateToConfig do
    it 'delegates Options getter methods' do
      subject.authorize_url.should == 'https://graph.facebook.com'
    end

    it 'delegates Options setter methods' do
      url = 'http://facebook.com'
      subject.authorize_url = url
      subject.authorize_url.should == url
    end

    it 'overwritten Options stays that way' do
      config.access_token.should == :access_token
    end
  end

  context 'no config' do
    subject { OpenAuth2::Client.new }

    it 'defaults to OpenAuth2::Config' do
      subject = described_class.new
      subject.config.should be_a(OpenAuth2::Config)
    end

    it 'makes public request' do
      VCR.use_cassette('facebook/cocacola') do
        url = 'https://graph.facebook.com/cocacola'
        request = subject.get(url)
        request.status.should == 200
      end
    end

    it 'makes private request' do
      VCR.use_cassette('facebook/me') do
        url = "https://graph.facebook.com/me/likes?access_token=#{Creds['Facebook']['AccessToken']}"
        request = subject.get(url)
        request.status.should == 200
      end
    end
  end
end
