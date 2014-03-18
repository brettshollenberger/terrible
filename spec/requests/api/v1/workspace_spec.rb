require 'spec_helper'

describe "Workspaces API" do

  describe "index" do
    before(:each) do
      FactoryGirl.create_list(:workspace, 10)
    end

    describe "when not logged in" do
      before(:each) do
        get "/api/v1/workspaces.json"
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
        FactoryGirl.create(:user_workspace_collaboration, collaborator: user)
        login(user)
        get "/api/v1/workspaces.json"
      end

      it "is a successful request" do
        expect(response).to be_success
      end

      it "responds with a list of workspaces the user collaborates on" do
        expect(json.length).to eq(1)
      end
    end
  end
end
