require 'spec_helper'

describe Workspace do
  before(:each) do
    @uwc       = FactoryGirl.create(:user_workspace_collaboration)
    @workspace = @uwc.collaboratable
    @user      = @uwc.collaborator
    @upc       = FactoryGirl.create(:user_project_collaboration,
                                    collaborator: @user)

    @project           = @upc.collaboratable
    @project.workspace = @workspace
    @project.save
  end

  it "is valid" do
    expect(@workspace).to be_valid
  end

  it "is invalid if it contains no name" do
    @workspace.name = nil
    expect(@workspace).to_not be_valid
  end
end
