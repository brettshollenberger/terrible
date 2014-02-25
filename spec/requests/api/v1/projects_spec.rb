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

  describe "create" do
    before(:each) do
      def valid_project
        { :format => :json, :project => { :title => "A great project" } }
      end

      def project_create_endpoint
        "/api/v1/projects.json"
      end

      def create_project(project)
        post project_create_endpoint, project
      end
    end

    describe "when logged in" do

      before(:each) do
        login(user)
      end

      describe "when creating a valid project" do
        before(:each) do
          create_project(valid_project)
        end

        it "is a successful request" do
          expect(response).to be_success
        end

        it "renders the project" do
          expect(json["title"]).to eql("A great project")
        end
      end
    end

    describe "when not logged in" do
      before(:each) do
        create_project(valid_project)
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
      @upc = FactoryGirl.create(:user_project_collaboration, collaborator: user)
      @user2 = FactoryGirl.create(:user)
      @project = @upc.collaboratable
      login(user)

      def project_json
        { :format => :json, :project => { :title => "Updated" } }
      end

      def project_update_endpoint
        "/api/v1/projects/#{@project.id}.json"
      end

      def update_project(project)
        put project_update_endpoint, project
      end
    end

    describe "when logged in" do
      describe "as a project collaborator" do
        before(:each) do
          update_project(project_json)
        end

        it "is a successful request" do
          expect(response).to be_success
        end

        it "renders the updated project" do
          expect(json["title"]).to eql("Updated")
        end
      end

      describe "as a non-collaborator" do
        before(:each) do
          logout
          login(@user2)
          update_project(project_json)
        end

        it "is not a successful request" do
          expect(response).to_not be_success
        end

        it "returns status 401" do
          expect(json["status"]).to eql("401")
        end
      end

      describe "when the project doesn't exist" do
        before(:each) do
          put "/api/v1/projects/not-an-id.json", project_json
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
        update_project(project_json)
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
