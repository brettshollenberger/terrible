require 'spec_helper'

describe "Projects API :" do

  before(:each) do
    @workspace        = workspace_for_user(user)
    @project          = project_in_workspace(@workspace)
    @random_workspace = FactoryGirl.create(:workspace)
    @random_project   = project_in_workspace(@random_workspace)
  end

  describe "Index Action :" do
    before(:each) do
      FactoryGirl.create_list(:project, 10)
    end

    describe "When request is nested by workspace :" do
      describe "When not logged in :" do
        before(:each) do
          get api_v1_workspace_projects_path(@workspace)
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

        describe "When user is not a collaborator on workspace :" do
          before(:each) do
            get api_v1_workspace_projects_path(@random_workspace)
          end

          it "It is not a successful request" do
            expect(response).to_not be_success
          end

          it "It responds with an error message" do
            expect(json["error"]).to eq("You don't have permission to view or modify that resource")
          end
        end

        describe "When user is a collaborator on workspace :" do
          before(:each) do
            get api_v1_workspace_projects_path(@workspace)
          end

          it "It is a successful request" do
            expect(response).to be_success
          end

          it "It responds with the projects nested by workspace" do
            expect(json.length).to eq(1)
            expect(json[0]["title"]).to eql("Workspaced Project")
          end
        end
      end
    end

    describe "When request is not nested by workspace :" do
      describe "When not logged in :" do
        before(:each) do
          get api_v1_projects_path
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
          @workspace2 = workspace_for_user(user)
          project_in_workspace(@workspace2)
          get api_v1_projects_path
        end
        it "is a successful request" do
          expect(response).to be_success
        end

        it "responds with a list of projects the user collaborates on" do
          expect(json.length).to eq(2)
        end
      end
    end
  end

  describe "Show Action :" do
    describe "When request is nested by workspace :" do

      describe "When not logged in :" do
        before(:each) do
          get api_v1_workspace_project_path(@workspace, @project)
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

        describe "When user is a collaborator on workspace :" do
          before(:each) do
            @workspace = workspace_for_user(user)
            @project   = project_in_workspace(@workspace)
            get api_v1_workspace_project_path(@workspace, @project)
          end

          it "It is a successful request" do
            expect(response).to be_success
          end

          it "It responds with the project" do
            expect(json["title"]).to eql("Workspaced Project")
          end
        end

        describe "When user is not a collaborator on workspace :" do
          before(:each) do
            get api_v1_workspace_project_path(@random_workspace, @random_project)
          end

          it "It is not a successful request" do
            expect(response).to_not be_success
          end

          it "It responds with an error message" do
            expect(json["error"]).to eq("You don't have permission to view or modify that resource")
          end
        end
      end
    end

    describe "When the request is not nested by workspace :" do
      describe "When logged in :" do
        before(:each) do
          login(user)
        end

        describe "When the user is a collaborator on the project :" do
          before(:each) do
            @workspace = workspace_for_user(user)
            @project   = project_in_workspace(@workspace)
            get api_v1_project_path(@project)
          end

          it "It is a successful request" do
            expect(response).to be_success
          end

          it "It responds with the user's project" do
            expect(json["title"]).to eql(@project.title)
          end
        end

        describe "When the user is not a collaborator on the project :" do
          before(:each) do
            get api_v1_project_path(@random_project)
          end

          it "It is not a successful request" do
            expect(response).to_not be_success
          end

          it "It returns an error message" do
            expect(json["error"]).to eql("You don't have permission to view or modify that resource")
          end
        end

        describe "When the resource does not exist :" do
          before(:each) do
            get "/api/v1/projects/not-an-id.json"
          end

          it "It is not a successful request" do
            expect(response).to_not be_success
          end

          it "It returns an error message" do
            expect(json["error"]).to eql("Resource not found")
          end
        end
      end
    end
  end

  describe "Create Action :" do
    before(:each) do
      def valid_project_json
        { :format => :json, :project => { :title => "A great project" } }
      end
    end

    describe "When logged in :" do
      before(:each) do
        login(user)
      end

      describe "When creating a valid project :" do
        before(:each) do
          post "/api/v1/workspaces/#{@workspace.id}/projects", valid_project_json
          @project = Project.find(json["id"])
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the project" do
          expect(json["title"]).to eql("A great project")
        end

        it "It creates a collaboratorship between user and project" do
          expect(user.projects.last).to eql(@project)
        end

        it "It creates an active collaboratorship" do
          expect(user.collaboratorship_for(@project).state).to eql("active")
        end

        it "It makes the user the owner" do
          expect(user.role_for(@project)).to eql("owner")
        end
      end
    end

    describe "When not logged in :" do
      before(:each) do
        post "/api/v1/workspaces/#{@workspace.id}/projects", valid_project_json
      end

      it "It is not a successful request" do
        expect(response).to_not be_success
      end

      it "It renders the login message" do
        expect(json["error"]).to eql("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "Update Action :" do
    before(:each) do
      login(user)

      def update_project_json
        { :format => :json, :project => { :title => "Updated" } }
      end
    end

    describe "When logged in :" do
      describe "As a project collaborator :" do
        before(:each) do
          @workspace = workspace_for_user(user)
          @project   = project_in_workspace(@workspace)
          put "/api/v1/workspaces/#{@workspace.id}/projects/#{@project.id}", update_project_json
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the updated project" do
          expect(json["title"]).to eql("Updated")
        end
      end

      describe "As a non-project-collaborator :" do
        before(:each) do
          put "/api/v1/workspaces/#{@random_workspace.id}/projects/#{@random_project.id}", update_project_json
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It returns status 401" do
          expect(json["status"]).to eql("401")
        end
      end

      describe "When the project doesn't exist :" do
        before(:each) do
          put "/api/v1/workspaces/#{@workspace.id}/projects/not-an-id.json", update_project_json
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It returns status 404" do
          expect(json["status"]).to eql("404")
        end
      end
    end

    describe "When not logged in :" do
      before(:each) do
        logout
        put "/api/v1/workspaces/#{@workspace.id}/projects/#{@project.id}", update_project_json
      end

      it "It is not successful" do
        expect(response).to_not be_success
      end

      it "It renders the login message" do
        expect(json["error"]).to eql("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "delete" do
    describe "when logged in and able to delete the project" do
      before(:each) do
        @workspace = workspace_for_user(user)
        @project   = project_in_workspace(@workspace)
        login(user)
        delete "/api/v1/workspaces/#{@workspace.id}/projects/#{@project.id}.json"
      end

      it "is a successful request" do
        expect(response).to be_success
      end

      it "returns a message stating that the project has been removed" do
        expect(json["message"]).to eql("Resource successfully deleted.")
      end
    end
  end
end
