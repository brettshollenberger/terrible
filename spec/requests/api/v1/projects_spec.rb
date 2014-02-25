require 'spec_helper'

describe "Projects API" do

  describe "index" do
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

      it "responds with a list of projects the user collaborates on" do
        expect(json.length).to eq(1)
      end
    end
  end

  describe "show" do
    describe "when logged in and able to view the project" do
      before(:each) do
        @upc = FactoryGirl.create(:user_project_collaboration, collaborator: user)
        @project = @upc.collaboratable
        login(user)
        get "/api/v1/projects/#{@project.id}.json"
      end

      it "is a successful request" do
        expect(response).to be_success
      end

      it "responds with the user's project, provided they are a collaborator" do
        expect(json["title"]).to eql(@project.title)
      end
    end

    describe "when logged in and not able to view the project" do
      before(:each) do
        @upc = FactoryGirl.create(:user_project_collaboration)
        @project = @upc.collaboratable
        login(user)
        get "/api/v1/projects/#{@project.id}.json"
      end

      it "is not a successful request" do
        expect(response).to_not be_success
      end

      it "returns an error message" do
        expect(json["message"]).to eql("You don't have permission to view that resource")
      end
    end
  end
end
