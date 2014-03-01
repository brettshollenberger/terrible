require "spec_helper"

describe Collaborations::Collaboratorable do

  before(:each) do
    @collaboratorship         = FactoryGirl.create(:user_project_collaboration)
    @user                     = @collaboratorship.collaborator
    @pending_collaboratorship = FactoryGirl.create(:pending_user_project_collaboration,
                                                  collaborator: @user)
    @ownership                = FactoryGirl.create(:user_project_ownership,
                                                  collaborator: @user)
    @project                  = @collaboratorship.collaboratable
    @pending_project          = @pending_collaboratorship.collaboratable
    @owned_project            = @ownership.collaboratable
  end

  it "finds active collaboratorships" do
    expect(@user.active_collaboratorships).to include(@collaboratorship)
  end

  it "finds active projects" do
    expect(@user.active_projects).to include(@project)
  end

  it "finds pending projects" do
    expect(@user.pending_projects).to include(@pending_project)
  end

  it "finds pending collaboratorships" do
    expect(@user.pending_collaboratorships).to include(@pending_collaboratorship)
  end

  it "finds the collaboratorship for a collaboratable" do
    expect(@user.collaboratorship_for(@project)).to eql(@collaboratorship)
  end

  it "finds the role for a collaboration" do
    expect(@user.role_for(@pending_project)).to eql("collaborator")
  end

  it "finds the state of a collaboration" do
    expect(@user.state_for(@pending_project)).to eql("pending")
  end

  it "verifies ownership" do
    expect(@user.owner?(@owned_project)).to eql(true)
  end

  it "verifies collaboratorship" do
    expect(@user.collaborator?(@project)).to eql(true)
  end

  it "is not a collaborator if the state is not active" do
    expect(@user.collaborator?(@pending_project)).to eql(false)
  end
end
