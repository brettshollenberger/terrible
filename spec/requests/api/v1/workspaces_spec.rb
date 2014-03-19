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

  describe "show" do
    describe "when logged in and able to view the workspace" do
      before(:each) do
        @uwc       = FactoryGirl.create(:user_workspace_collaboration, collaborator: user)
        @workspace = @uwc.collaboratable
        login(user)
        get "/api/v1/workspaces/#{@workspace.id}.json"
      end

      it "is a successful request" do
        expect(response).to be_success
      end

      it "responds with the user's workspace, provided they are a collaborator" do
        expect(json["name"]).to eql(@workspace.name)
      end
    end

    describe "when logged in and not able to view the workspace" do
      before(:each) do
        @uwc       = FactoryGirl.create(:user_workspace_collaboration)
        @workspace = @uwc.collaboratable
        login(user)
        get "/api/v1/workspaces/#{@workspace.id}.json"
      end

      it "is not a successful request" do
        expect(response).to_not be_success
      end

      it "returns an error message" do
        expect(json["message"]).to eql("You don't have permission to view that resource")
      end
    end
  end

  describe "create" do
    before(:each) do
      def valid_workspace
        { :format => :json, :workspace => { :name => "The Best Workspace" } }
      end

      def workspace_create_endpoint
        "/api/v1/workspaces.json"
      end

      def create_workspace(workspace)
        post workspace_create_endpoint, workspace
      end
    end

    describe "when logged in" do
      before(:each) do
        login(user)
      end

      describe "when creating a valid workspace" do
        before(:each) do
          create_workspace(valid_workspace)
          @workspace = Workspace.find(json["id"])
        end

        it "is a successful request" do
          expect(response).to be_success
        end

        it "renders the workspace" do
          expect(json["name"]).to eql("The Best Workspace")
        end

        it "creates a collaboratorship between user and workspace" do
          expect(user.workspaces[0]).to eql(@workspace)
        end

        it "creates an active collaboratorship" do
          expect(user.collaboratorship_for(@workspace).state).to eql("active")
        end

        it "makes the user the owner" do
          expect(user.role_for(@workspace)).to eql("owner")
        end
      end
    end

    describe "when not logged in" do
      before(:each) do
        create_workspace(valid_workspace)
      end

      it "is not a successful request" do
        expect(response).to_not be_success
      end

      it "renders the login message" do
        expect(json["error"]).to eql("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "update" do
    before(:each) do
      @uwc       = FactoryGirl.create(:user_workspace_collaboration, collaborator: user)
      @user2     = FactoryGirl.create(:user)
      @workspace = @uwc.collaboratable
      login(user)

      def workspace_json
        { :format => :json, :workspace => { :name => "Updated" } }
      end

      def workspace_update_endpoint
        "/api/v1/workspaces/#{@workspace.id}.json"
      end

      def update_workspace(workspace)
        put workspace_update_endpoint, workspace
      end
    end

    describe "when logged in" do
      describe "as a workspace collaborator" do
        before(:each) do
          update_workspace(workspace_json)
        end

        it "is a successful request" do
          expect(response).to be_success
        end

        it "renders the updated workspace" do
          expect(json["name"]).to eql("Updated")
        end
      end

      describe "as a non-collaborator" do
        before(:each) do
          logout
          login(@user2)
          update_workspace(workspace_json)
        end

        it "is not a successful request" do
          expect(response).to_not be_success
        end

        it "returns status 401" do
          expect(json["status"]).to eql("401")
        end
      end

      describe "when the workspace doesn't exist" do
        before(:each) do
          put "/api/v1/workspaces/not-an-id.json", workspace_json
        end

        it "is not a successful request" do
          expect(response).to_not be_success
        end

        it "returns status 404" do
          expect(json["status"]).to eql("404")
        end
      end
    end

    describe "when not logged in" do
      before(:each) do
        logout
        update_workspace(workspace_json)
      end

      it "is not successful" do
        expect(response).to_not be_success
      end

      it "renders the login message" do
        expect(json["error"]).to eql("You need to sign in or sign up before continuing.")
      end
    end
  end
end
