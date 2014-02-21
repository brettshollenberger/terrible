require 'spec_helper'

describe "Projects API" do

  describe "when not logged in" do
    before(:each) do
      FactoryGirl.create_list(:project, 10)
      get "/api/v1/projects.json"
    end

    it "is not a successful request" do
      expect(response).to_not be_success
    end

    it "responds with an error message" do
      expect(json["error"]).to eq("You need to sign in or sign up before continuing.")
    end
  end

  describe "when logged in" do
    before(:each) do
      FactoryGirl.create_list(:project, 10)
      FactoryGirl.create(:user_project_collaboration, collaborator: user)
      login(user)
      get "/api/v1/projects.json"
    end

    it "is a successful request" do
      expect(response).to be_success
    end

    it "responds with a list of projects" do
      expect(json.length).to eq(1)
    end
  end
end
