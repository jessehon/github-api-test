require 'rails_helper'

RSpec.describe GithubApi::Client do
  let(:client) { GithubApi::Client.new }

  describe '#fetch_user_organizations' do
    let(:username) { 'gaearon' }

    context 'when valid' do
      # Load fixture for Github API response
      let(:response_json) do
        File.new(Rails.root.join('spec', 'fixtures', 'github_api', "#{username}_organizations.json"))
      end

      # Stub Github API response
      before(:each) do
        stub_request(:get, "https://api.github.com/users/#{username}/orgs")
          .to_return(status: 200, body: response_json)
      end

      it 'returns correct entries' do
        user_organizations = client.fetch_user_organizations(username: username)
        expect(user_organizations.size).to eq(2)
        expect(user_organizations[0]).to have_attributes(id: 69631)
        expect(user_organizations[1]).to have_attributes(id: 9637642)
      end
    end

    context 'when github responds 404' do
      # Stub Github API response with 404 error
      before(:each) do
        stub_request(:get, "https://api.github.com/users/#{username}/orgs")
          .to_return(status: 404, body: nil)
      end

      it 'raises a GithubApi::Exceptions::BadRequest' do
        expect { client.fetch_user_organizations(username: username) }.to raise_error(GithubApi::Exceptions::BadRequest)
      end
    end
  end
end
