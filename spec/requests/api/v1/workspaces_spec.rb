require 'spec_helper'

describe "Workspaces API :" do

  before(:each) do
    FactoryGirl.create_list(:workspace, 10)
    @workspace        = workspace_for_user(user)
    @random_workspace = FactoryGirl.create(:workspace)
  end

  describe "Index Action :" do
    describe "When not logged in :" do
      before(:each) do
        get api_v1_workspaces_path
      end

      it "It is not a successful request" do
        expect(response).to_not be_success
      end

      it "It responds with an error message" do
        expect(json["error"]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    describe "When logged in :" do
      before(:each) do
        login(user)
      end

      describe "When no query params are passed :" do
        before(:each) do
          get api_v1_workspaces_path
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with a list of workspaces that the user collaborates on" do
          expect(json.length).to eq(1)
          expect(json[0]["name"]).to eq(@workspace.name)
        end
      end

      describe "When query params are passed :" do
        before(:each) do
          10.times { |n| workspace_for_user(user) }
          @w      = Workspace.last
          @w.name = "The last workspace"
          @w.save
        end

        describe "When the request does not fuzzy filter :" do
          before(:each) do
            get "/api/v1/workspaces", {name: "The last workspace"}
          end

          it "It is a successful request" do
            expect(response).to be_success
          end

          it "It responds with only the filtered workspaces that exactly match the query" do
            expect(json.length).to eq(1)
            expect(json[0]["name"]).to eq("The last workspace")
          end
        end

        describe "When the request fuzzy filters :" do
          before(:each) do
            get "/api/v1/workspaces", {name: "workspace", fuzzy: true}
          end

          it "It is a successful request" do
            expect(response).to be_success
          end

          it "It responds with only the filtered workspaces that match the fuzzy request" do
            expect(json.length).to eq(11)
            expect(json[0]["name"]).to eq("The first workspace")
          end
        end

        describe "When the request may match any queryable parameter :" do
          before(:each) do
            get "/api/v1/workspaces", {any: "The last workspace"}
          end

          it "It is a successful request" do
            expect(response).to be_success
          end

          it "It responds with only the filtered workspaces that match the request" do
            expect(json.length).to eq(1)
            expect(json[0]["name"]).to eq("The last workspace")
          end
        end

        describe "When the request may match any queryable parameter and is fuzzy :" do
          before(:each) do
            get "/api/v1/workspaces", {any: "workspace", fuzzy: true}
          end

          it "It is a successful request" do
            expect(response).to be_success
          end

          it "It responds with only the filtered workspaces that match the request" do
            expect(json.length).to eq(11)
            expect(json[0]["name"]).to eq("The first workspace")
          end
        end
      end
    end
  end

  describe "Show Action :" do
    describe "When not logged in :" do
      before(:each) do
        get api_v1_workspace_path(@workspace)
      end

      it "It is not a successful request" do
        expect(response).to_not be_success
      end

      it "It responds with an error message" do
        expect(json["error"]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    describe "When logged in :" do
      before(:each) do
        login(user)
      end

      describe "When the user may view the workspace :" do
        before(:each) do
          get api_v1_workspace_path(@workspace)
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with the user's workspace, provided they are a collaborator" do
          expect(json["name"]).to eql(@workspace.name)
        end
      end

      describe "When the user may not view the workspace :" do
        before(:each) do
          get api_v1_workspace_path(@random_workspace)
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It returns an error message" do
          expect(json["error"]).to eql("You don't have permission to view or modify that resource")
        end
      end
    end
  end

  describe "Create Action :" do
    before(:each) do
      def valid_workspace_json
        { :format => :json, :workspace => { :name => "The Best Workspace" } }
      end
    end

    describe "When not logged in :" do
      before(:each) do
        post api_v1_workspaces_path(valid_workspace_json)
      end

      it "is not a successful request" do
        expect(response).to_not be_success
      end

      it "renders the login message" do
        expect(json["error"]).to eql("You need to sign in or sign up before continuing.")
      end
    end

    describe "When logged in :" do
      before(:each) do
        login(user)
      end

      describe "If I create a valid workspace :" do
        before(:each) do
          post api_v1_workspaces_path(valid_workspace_json)
          @recently_created_workspace = Workspace.find(json["id"])
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently created workspace" do
          expect(json["name"]).to eql("The Best Workspace")
        end

        it "It creates a collaboratorship between user and recently created workspace" do
          expect(user.workspaces.last).to eql(@recently_created_workspace)
        end

        it "It creates an active collaboratorship" do
          expect(user.collaboratorship_for(@recently_created_workspace).state).to eql("active")
        end

        it "It makes the user the owner" do
          expect(user.role_for(@recently_created_workspace)).to eql("owner")
        end
      end
    end
  end

  describe "Update Action :" do
    before(:each) do
      def update_workspace_json
        { :format => :json, :workspace => { :name => "Updated" } }
      end
    end

    describe "When not logged in :" do
      before(:each) do
        put api_v1_workspace_path(@workspace, update_workspace_json)
      end

      it "It is not successful" do
        expect(response).to_not be_success
      end

      it "It renders the login message" do
        expect(json["error"]).to eql("You need to sign in or sign up before continuing.")
      end
    end

    describe "When logged in :" do
      before(:each) do
        login(user)
      end

      describe "As a workspace collaborator :" do
        before(:each) do
          put api_v1_workspace_path(@workspace, update_workspace_json)
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the updated workspace" do
          expect(json["name"]).to eql("Updated")
        end
      end

      describe "As a non-collaborator on the workspace :" do
        before(:each) do
          @user2 = FactoryGirl.create(:user)
          login(@user2)
          put api_v1_workspace_path(@workspace, update_workspace_json)
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It returns status 401" do
          expect(json["status"]).to eql("401")
        end
      end

      describe "When the workspace doesn't exist :" do
        before(:each) do
          put "/api/v1/workspaces/not-an-id.json", update_workspace_json
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It returns status 404" do
          expect(json["status"]).to eql("404")
        end
      end
    end
  end

  describe "Delete Action :" do

    describe "When not logged in :" do
      before(:each) do
        delete api_v1_workspace_path(@workspace)
      end

      it "It is not successful" do
        expect(response).to_not be_success
      end

      it "It renders the login message" do
        expect(json["error"]).to eql("You need to sign in or sign up before continuing.")
      end
    end

    describe "When logged in :" do
      before(:each) do
        login(user)
      end

      describe "When the user may delete the workspace :" do
        before(:each) do
          delete api_v1_workspace_path(@workspace)
        end

        it "is a successful request" do
          expect(response).to be_success
        end

        it "returns a message stating that the workspace has been removed" do
          expect(json["message"]).to eql("Resource successfully deleted.")
        end
      end

      describe "When the user may not delete the workspace :" do
        before(:each) do
          delete api_v1_workspace_path(@random_workspace)
        end

        it "is not a successful request" do
          expect(response).to_not be_success
        end

        it "returns a message stating the not permitted error" do
          expect(json["error"]).to eql("You don't have permission to view or modify that resource")
        end
      end
    end
  end
end
